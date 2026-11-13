plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.neducate.favorite_collection_sale"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.neducate.favorite_collection_sale"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyPath = System.getenv("KEYSTORE_PATH") ?: "keystore.jks"
            val keyAliasVar = System.getenv("KEY_ALIAS") ?: "favorite_collection"
            val keyPasswordVar = System.getenv("KEY_PASSWORD") ?: "FavoriteCollection2026!"
            val storePasswordVar = System.getenv("STORE_PASSWORD") ?: "FavoriteCollection2026!"

            val keyFile = file(keyPath)
            if (keyFile.exists()) {
                storeFile = keyFile
                storePassword = storePasswordVar
                keyAlias = keyAliasVar
                keyPassword = keyPasswordVar
            } else {
                val altFile = file("../app/$keyPath")
                if (altFile.exists()) {
                    storeFile = altFile
                    storePassword = storePasswordVar
                    keyAlias = keyAliasVar
                    keyPassword = keyPasswordVar
                } else {
                    val debugKey = signingConfigs.getByName("debug")
                    if (debugKey.storeFile != null && debugKey.storeFile!!.exists()) {
                        storeFile = debugKey.storeFile
                        storePassword = debugKey.storePassword
                        keyAlias = debugKey.keyAlias
                        keyPassword = debugKey.keyPassword
                    }
                }
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            if (releaseConfig.storeFile != null && releaseConfig.storeFile!!.exists()) {
                signingConfig = releaseConfig
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
