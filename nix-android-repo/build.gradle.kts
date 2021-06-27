import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm")
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
}

tasks {
    withType<KotlinCompile> {
        kotlinOptions {
            jvmTarget = "11"
        }
    }

    register("downloadSources") {
        doLast {
            val componentIds = configurations.filter { it.isCanBeResolved }
                .flatMap { c -> c.incoming.resolutionResult.allComponents }
                .map { it.id }

            project.dependencies.createArtifactResolutionQuery()
                .forComponents(componentIds)
                .withArtifacts(JvmLibrary::class.java, SourcesArtifact::class.java)
                .execute()
                .resolvedComponents
                .flatMap { it.getArtifacts(SourcesArtifact::class.java) }
                .filterIsInstance<ResolvedArtifactResult>()
        }
    }
}
