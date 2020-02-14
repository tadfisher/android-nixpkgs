package codes.tad.nixandroidrepo

import java.io.File
import java.io.PrintStream
import java.nio.file.Files
import kotlin.system.exitProcess

fun main(args: Array<String>) {
    if (args.isEmpty()) usage()

    val defaults = mapOf(
        "out" to "generate.nix",
        "xml" to "xml",
        "channel" to "stable"
    )

    val options = defaults.plus(args.map { s ->
        s.removePrefix("--").split("=").let {
            if (it.size == 1) it[0] to "" else it[0] to it.drop(1).joinToString("")
        }
    })

    if (options.keys.any { it == "h" || it == "help" }) usage()

    options.keys.find { it !in defaults.keys }?.let {
        usage(System.err, "Invalid argument: $it")
    }

    val out = try {
        File(options.getValue("out")).also { it.parentFile.mkdirs() }
    } catch (e: Exception) {
        usage(System.err, "out: Not a file: ${options["out"]}")
    }

    val xml = try {
        File(options.getValue("xml")).also { it.mkdirs() }
    } catch (e: Exception) {
        usage(System.err, "xml: Not a directory: ${options["xml"]}")
    }

    val channel = when (options["channel"]) {
        "stable" -> 0
        "beta" -> 1
        "preview" -> 2
        "canary" -> 3
        else -> usage(System.err, "channel: Not a channel: ${options["channel"]}")
    }

    val tmp = Files.createTempDirectory("nix-android")
    tmp.toFile().deleteOnExit()
    val repo = NixRepoManager(tmp, channel)

    print("fetching ${options["channel"]} packages... ")
    val packages = repo.getPackages()
    println("${packages.remotePackages.size} packages found")

    print("generating... ")
    val nixRepo = packages.nixRepo()
    val generatedNix = nixRepo.nix().formatIndents()
    out.writeText(generatedNix)
    println("${nixRepo.packages.size} packages generated")

    print("writing package xml... ")
    for (pkg in packages.remotePackages.values) {
        xml.resolve(pkg.path.pname() + ".xml").writeText(repo.packageXml(pkg))
    }
    println("done")

    exitProcess(0)
}

fun usage(out: PrintStream = System.out, message: String = ""): Nothing {
    if (message.isNotBlank()) out.println("$message\n")
    out.println("""
        Usage: nix-android-repo [ OPTION ... ]

        Options:
          --out=<outPath>: Write generated Nix expression to this file.

          --xml=<xmlDir>: Write package XML documents to this directory.

          --channel=<name>: Android repository channel, one of:
                              stable
                              beta
                              preview
                              canary
    """.trimIndent())
    if (out == System.err) exitProcess(1) else exitProcess(0)
}
