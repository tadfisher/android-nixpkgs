@file:Suppress("UnstableApiUsage")

val REPOS_PROPERTY = "nix.repos"

fun RepositoryHandler.configure(repos: Provider<List<String>>) {
    if (repos.isPresent) {
        clear()
        for (url in repos.get()) {
            maven(url)
        }
    }
}

val systemRepos: Provider<String> =
    providers.systemProperty(REPOS_PROPERTY)
val gradleRepos: Provider<String> =
    providers.gradleProperty(REPOS_PROPERTY)
val repos: Provider<List<String>> =
    systemRepos.orElse(gradleRepos).map { it.split(',') }

pluginManagement.repositories.configure(repos)
dependencyResolutionManagement.repositories.configure(repos)

buildscript {
    configurations.classpath {
        resolutionStrategy.activateDependencyLocking()
    }
}
