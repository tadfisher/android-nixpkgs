import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

buildscript {
    repositories {
        if (gradle.startParameter.isOffline) {
            flatDir { dir("gradle/offlineRepo") }
        } else {
            jcenter()
        }
    }
    dependencies {
        classpath(embeddedKotlin("compiler-embeddable"))
        classpath(embeddedKotlin("reflect"))
    }
}

plugins {
    kotlin("jvm") version(embeddedKotlinVersion)
    application
}

application {
    mainClassName = "codes.tad.nixandroidrepo.MainKt"
}

repositories {
    jcenter()
    google()
    if (gradle.startParameter.isOffline) {
        flatDir { dir("gradle/offlineRepo") }
    }
}

dependencies {
    implementation(kotlin("stdlib-jdk8"))
    implementation("com.android.tools:sdklib:26.6.0-alpha01")
}

tasks {
    withType<KotlinCompile> {
        kotlinOptions {
            jvmTarget = "1.8"
        }
    }

    register("offlineRepo", Copy::class) {
        configurations.all { if (isCanBeResolved) from(copyRecursive()) }
        buildscript.configurations.all { from(copyRecursive()) }
        into("gradle/offlineRepo")
    }

    withType<Wrapper> {
        gradleVersion = "5.4.1"
    }
}
