plugins {
    id("com.android.application")
    id("kotlin-android")  // Оставил alias; если ошибка — замени на "org.jetbrains.kotlin.android"
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.pressure_diary_fresh"  // Поменяй при необходимости
    compileSdk = 36  // Обновлено до 36 для совместимости с плагинами

    defaultConfig {
        applicationId = "com.example.pressure_diary_fresh"
        minSdk = flutter.minSdkVersion
        targetSdk = 36  // Обновлено до 36
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlin {
    // для современных AGP: kotlin {} предпочтительнее, чем kotlinOptions {}
    jvmToolchain(17)
    }
    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/LICENSE*",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }
}

// Добавлено: Подавление предупреждений о obsolete options для Java-компиляции (от desugaring и зависимостей)
tasks.withType<org.gradle.api.tasks.compile.JavaCompile> {
    options.compilerArgs.addAll(listOf("-Xlint:-options"))
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

}
