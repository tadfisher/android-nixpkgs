import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    alias(libs.plugins.kotlin.jvm)
    application
}

application {
    mainClass.set("codes.tad.nixandroidrepo.MainKt")
}

dependencyLocking {
    lockAllConfigurations()
}

dependencies {
    implementation(libs.common)
    implementation(libs.sdklib)
    implementation(libs.coroutines)
    implementation(libs.jaxb.api)
    implementation(libs.jaxb.runtime)
}

tasks {
    wrapper {
        gradleVersion = libs.versions.gradle.get()
    }
}
