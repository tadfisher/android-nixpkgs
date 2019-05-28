package codes.tad.nixandroidrepo

import com.android.repository.api.Channel
import com.android.repository.api.Downloader
import com.android.repository.api.ProgressIndicator
import com.android.repository.api.ProgressIndicatorAdapter
import com.android.repository.api.RemotePackage
import com.android.repository.api.RepoManager
import com.android.repository.api.SettingsController
import com.android.repository.impl.meta.LocalPackageImpl
import com.android.repository.impl.meta.RepositoryPackages
import com.android.repository.impl.meta.SchemaModuleUtil
import com.android.sdklib.repository.AndroidSdkHandler
import com.android.sdklib.tool.sdkmanager.SdkManagerCli
import org.apache.http.Header
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.InputStream
import java.io.PrintStream
import java.net.URL
import java.nio.file.Path
import com.android.sdklib.repository.installer.SdkInstallerUtil
import com.android.repository.api.Installer
import com.android.repository.api.PackageOperation
import com.android.repository.io.FileOp

class NixDownloader(localPath: Path) : Downloader {
    override fun downloadFully(url: URL, indicator: ProgressIndicator): Path? {
        val target = File.createTempFile("NixDownloader", null)
        downloadFully(url, target, null, indicator)
        return target.toPath()
    }

    override fun downloadFully(
        url: URL,
        target: File,
        checksum: String?,
        indicator: ProgressIndicator
    ) {
        if (target.exists() && checksum != null) {
            indicator.setText("Verifying previous download...")
            target.inputStream().buffered().use { stream ->
                if (checksum == Downloader.hash(stream, target.length(), indicator.createSubProgress(0.3))) {
                    return
                }
            }
        }
        println("Should download: $url -> $target")
    }

    override fun downloadAndStream(url: URL, indicator: ProgressIndicator): InputStream? {
        return openUrl(url.toString())
    }

    private fun openUrl(
        url: String,
        headers: Array<Header>? = null
    ): InputStream {
        val connection = URL(url).openConnection()
        if (headers != null) {
            for (header in headers) {
                connection.setRequestProperty(header.name, header.value)
            }
        }
        connection.connect()
        return connection.getInputStream().ensureMarkReset()
    }

    private fun InputStream.ensureMarkReset(): InputStream {
        return if (!markSupported()) {
            try {
                readBytes().inputStream().also {
                    try { close() } catch (e: Exception) {}
                }
            } catch (e: Exception) {
                this
            }
        } else {
            this
        }
    }
}

class NixProgressIndicator(
    private val err: PrintStream = System.err
) : ProgressIndicatorAdapter() {
    override fun logWarning(s: String, e: Throwable?) {
        err.println("Warning: %s")
        e?.let { err.println(it.message) }
    }

    override fun logWarning(s: String) {
        logWarning(s, null)
    }

    override fun logError(s: String, e: Throwable?) {
        err.println("Error: %s")
        e?.let { err.println(it.message) }
        throw SdkManagerCli.UncheckedCommandFailedException()
    }

    override fun logError(s: String) {
        logError(s, null)
    }
}

class NixSettings(
    private val channelId: Int
) : SettingsController {
    override fun getDisableSdkPatches(): Boolean = true

    override fun setDisableSdkPatches(disable: Boolean) {}

    override fun getForceHttp(): Boolean = false

    override fun setForceHttp(force: Boolean) {}

    override fun getChannel(): Channel = Channel.create(channelId)
}

class NixRepoManager(
    localPath: Path,
    channelId: Int
) {
    private val progress = NixProgressIndicator()
    private val sdk = AndroidSdkHandler.getInstance(localPath.toFile())
    private val repoManager = sdk.getSdkManager(progress)
    private val settings = NixSettings(channelId)
    private val downloader = NixDownloader(localPath)

    fun getPackages(): RepositoryPackages {
        repoManager.loadSynchronously(0, progress, downloader, settings)
        return repoManager.packages
    }

    fun packageXml(pkg: RemotePackage): String {
        val factory = RepoManager.getCommonModule().createLatestFactory()
        val repo = factory.createRepositoryType()
        pkg.license?.let { repo.addLicense(it) }
        val impl = LocalPackageImpl.create(pkg)
        repo.setLocalPackage(impl)
        val element = factory.generateRepository(repo)
        return ByteArrayOutputStream().use { out ->
            SchemaModuleUtil.marshal(element, repoManager.schemaModules, out,
                repoManager.getResourceResolver(progress), progress)
            out.toString(Charsets.UTF_8.name())
        }
    }
}
