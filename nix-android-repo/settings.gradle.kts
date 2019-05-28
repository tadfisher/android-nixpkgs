if (gradle.startParameter.isOffline) {
    pluginManagement {
        repositories {
            flatDir { dir("gradle/offlineRepo") }
        }
        resolutionStrategy {
            eachPlugin {
                if (requested.id.id == "org.jetbrains.kotlin.jvm") {
                    useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:${requested.version}")
                }
            }
        }
    }
}