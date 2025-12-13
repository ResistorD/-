// android/settings.gradle.kts

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // Читаем путь к Flutter SDK
    val localProps = java.util.Properties()
    val localPropsFile = java.io.File(settingsDir, "local.properties")
    if (localPropsFile.exists()) {
        localPropsFile.inputStream().use { localProps.load(it) }
    }
    val flutterSdkPath =
        localProps.getProperty("flutter.sdk")
            ?: System.getenv("FLUTTER_HOME")
            ?: System.getenv("FLUTTER_SDK")
            ?: throw GradleException(
                "Flutter SDK path not found. " +
                "Set flutter.sdk in android/local.properties or FLUTTER_HOME/FLUTTER_SDK env var."
            )

    // Подключаем gradle-плагин Flutter из SDK
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.2" apply false
    id("com.android.library") version "8.7.2" apply false
    id("org.jetbrains.kotlin.android") version "2.1.20" apply false  // Обновлено для соответствия предупреждению
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "pressure_diary_fresh"
include(":app")