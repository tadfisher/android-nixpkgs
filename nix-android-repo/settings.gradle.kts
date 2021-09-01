@file:Suppress("UnstableApiUsage")

enableFeaturePreview("VERSION_CATALOGS")

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
    providers.systemProperty(REPOS_PROPERTY).forUseAtConfigurationTime()
val gradleRepos: Provider<String> =
    providers.gradleProperty(REPOS_PROPERTY).forUseAtConfigurationTime()
val repos: Provider<List<String>> =
    systemRepos.orElse(gradleRepos).map { it.split(',') }

pluginManagement.repositories.configure(repos)
dependencyResolutionManagement.repositories.configure(repos)

pluginManagement {
    plugins {
        kotlin("jvm") version "1.5.30"
    }
}

buildscript {
    configurations.classpath {
        resolutionStrategy.activateDependencyLocking()
    }
}
