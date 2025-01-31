package codes.tad.nixandroidrepo

import com.android.prefs.AndroidLocationsSingleton
import com.android.repository.api.Channel
import com.android.repository.api.Checksum
import com.android.repository.api.Downloader
import com.android.repository.api.ProgressIndicator
import com.android.repository.api.ProgressIndicatorAdapter
import com.android.repository.api.RemotePackage
import com.android.repository.api.Repository
import com.android.repository.api.RepositorySource
import com.android.repository.api.SchemaModule
import com.android.repository.api.SettingsController
import com.android.repository.impl.meta.LocalPackageImpl
import com.android.repository.impl.meta.RemotePackageImpl
import com.android.repository.impl.meta.SchemaModuleUtil
import com.android.sdklib.repository.AndroidSdkHandler
import com.android.sdklib.tool.sdkmanager.SdkManagerCli
import com.sun.xml.bind.marshaller.NamespacePrefixMapper
import java.io.ByteArrayOutputStream
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStream
import java.io.PrintStream
import java.net.URI
import java.net.URL
import java.nio.file.Path
import java.util.concurrent.ConcurrentHashMap
import javax.xml.bind.JAXBContext
import javax.xml.bind.JAXBException
import kotlin.io.path.exists
import kotlin.io.path.fileSize
import kotlin.io.path.inputStream
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

class NixDownloader : Downloader {
    override fun downloadFully(url: URL, indicator: ProgressIndicator): Path {
        val target = kotlin.io.path.createTempFile("NixDownloader")
        downloadFully(url, target, null, indicator)
        return target
    }

    override fun downloadFully(
        url: URL,
        target: Path,
        checksum: Checksum?,
        indicator: ProgressIndicator
    ) {
        if (target.exists() && checksum != null) {
            indicator.setText("Verifying previous download...")
            target.inputStream().buffered().use { stream ->
                if (checksum.value == Downloader.hash(
                        stream,
                        target.fileSize(),
                        checksum.type,
                        indicator.createSubProgress(0.3)
                    )) {
                    return
                }
            }
        }
        println("Should download: $url -> $target")
    }

    override fun downloadAndStream(url: URL, indicator: ProgressIndicator): InputStream {
        return openUrl(url.toString())
    }

    private fun openUrl(
        url: String,
    ): InputStream {
        val connection = URI.create(url).toURL().openConnection()
        connection.connect()
        return connection.getInputStream().ensureMarkReset()
    }

    private fun InputStream.ensureMarkReset(): InputStream {
        return if (!markSupported()) {
            try {
                readBytes().inputStream().also {
                    try { close() } catch (_: Exception) {}
                }
            } catch (e: Exception) {
                this
            }
        } else {
            this
        }
    }
}

object NixProgressIndicator : ProgressIndicatorAdapter() {
    private var err: PrintStream = System.err

    override fun logWarning(s: String, e: Throwable?) {
        err.println("Warning: %s".format(s))
        e?.let { err.println("${it.javaClass.name}: ${it.message}") }
    }

    override fun logWarning(s: String) {
        logWarning(s, null)
    }

    override fun logError(s: String, e: Throwable?) {
        err.println("Error: %s".format(s))
        e?.let { err.println("${it.javaClass.name}: ${it.message}") }
        throw SdkManagerCli.UncheckedCommandFailedException()
    }

    override fun logError(s: String) {
        logError(s, null)
    }
}

class NixSettings(
    private val channelId: Int
) : SettingsController {
    override fun getForceHttp(): Boolean = false

    override fun setForceHttp(force: Boolean) {}

    override fun getChannel(): Channel = Channel.create(channelId)
}

class NixRepoManager(
    channelId: Int
) {
    private val progress = NixProgressIndicator
    private val sdk = AndroidSdkHandler.getInstance(AndroidLocationsSingleton, null)
    private val repoManager = sdk.getSdkManager(progress)
    private val settings = NixSettings(channelId)
    private val downloader = NixDownloader()

    fun getPackages(): Map<String, RemotePackage> {
        val parsedPackages = mutableMapOf<RepositorySource, Collection<RemotePackage>>()

        val sources = repoManager.getSources(downloader, progress, true)

        runBlocking {
            for (source in sources) {
                launch(Dispatchers.IO) {
                    try {
                        val manifest = downloader.downloadAndStream(
                            URI.create(source.url).toURL(),
                            progress
                        )
                        parseSource(source, manifest, progress, parsedPackages)
                    } catch (e: FileNotFoundException) {
                        progress.logWarning("Not found: ${source.url}")
                    }
                }
            }
        }

        val channel = settings.channel
        val packages = mutableMapOf<String, RemotePackage>()

        for ((source, sourcePackages) in parsedPackages) {
            mergePackages(channel, source, sourcePackages, packages)
        }

        return packages
    }

    private fun parseSource(
        source: RepositorySource,
        manifest: InputStream,
        progress: ProgressIndicator,
        result: MutableMap<RepositorySource, Collection<RemotePackage>>,
    ) {
        val repo = SchemaModuleUtil.unmarshal(
            manifest,
            source.permittedModules,
            true,
            progress,
            source.url
        ) as? Repository
        if (repo != null) {
            result[source] = repo.remotePackage
        } else {
            progress.logWarning("Failed to parse repository source: ${source.displayName}")
        }
    }

    private fun mergePackages(
        channel: Channel,
        source: RepositorySource,
        packages: Collection<RemotePackage>,
        result: MutableMap<String, RemotePackage>
    ) {
        for (pkg in packages) {
            pkg as RemotePackageImpl
            val existing = result[pkg.path]
            if (existing != null) {
                if (existing.version > pkg.version) continue

                if (existing.version < pkg.version) {
                    pkg.source = source
                    result[pkg.path] = pkg
                } else {
                    existing as RemotePackageImpl
                    val existingArchives = existing.allArchives
                    for (archive in pkg.allArchives) {
                        if (existingArchives.none { it.platform() == archive.platform() }) {
                            existing.addArchive(archive)
                        }
                    }
                }
            } else if (pkg.channel <= channel) {
                pkg.source = source
                result[pkg.path] = pkg
            }
        }
    }

    fun packageXml(pkg: RemotePackage): String {
        val factory = pkg.createFactory()
        val repo = factory.createRepositoryType()
        pkg.license?.let { repo.addLicense(it) }
        val impl = LocalPackageImpl.create(pkg)
        repo.setLocalPackage(impl)
        val element = factory.generateRepository(repo)
        val possibleModules = repoManager.schemaModules
        return ByteArrayOutputStream().use { out ->
            val context = getContext(possibleModules)
            try {
                val marshaller = context.createMarshaller()
                marshaller.setEventHandler { event ->
                    val prefix = "Parsing problem. "
                    if (event.linkedException != null) {
                        progress.logWarning(prefix + event.message, event.linkedException)
                    } else {
                        progress.logWarning(prefix + event.message)
                    }
                    false
                }
                marshaller.setProperty("com.sun.xml.bind.namespacePrefixMapper", ReproducibleNamespacePrefixMapper)
                marshaller.schema = SchemaModuleUtil.getSchema(
                    possibleModules,
                    repoManager.getResourceResolver(progress),
                    progress
                )
                marshaller.marshal(element, out)
            } catch (e: JAXBException) {
                progress.logWarning("Error during marshal", e)
            } catch (e: IOException) {
                progress.logWarning("Error during marshal", e)
            }
            out.toString(Charsets.UTF_8.name())
        }
    }


    private fun getContext(possibleModules: List<SchemaModule<*>>): JAXBContext {
        val key = possibleModules.flatMap { module ->
            module.namespaceVersionMap.values.map { it.objectFactory.`package`.name }
        }.sorted().joinToString(":")
        return CONTEXT_CACHE.getOrPut(key) {
            JAXBContext.newInstance(key, SchemaModuleUtil::class.java.classLoader)
        }
    }

    private object ReproducibleNamespacePrefixMapper : NamespacePrefixMapper() {
        override fun getPreferredPrefix(namespaceUri: String, suggestion: String?, requirePrefix: Boolean): String? {
            if (namespaceUri.startsWith("http://schemas.android.com/")) {
                return namespaceUri.removePrefix("http://schemas.android.com/")
                    .replace("/", "-")
            }
            if (namespaceUri == "http://www.w3.org/2001/XMLSchema-instance") {
                return "xsi"
            }
            return null
        }

    }

    companion object {
        private val CONTEXT_CACHE = ConcurrentHashMap<String, JAXBContext>()
    }
}
