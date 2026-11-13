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
            val keystorePath = System.getenv("KEYSTORE_PATH") ?: project.findProperty("KEYSTORE_PATH") as String?
            val keyAliasVar = System.getenv("KEY_ALIAS") ?: project.findProperty("KEY_ALIAS") as String?
            val keyPasswordVar = System.getenv("KEY_PASSWORD") ?: project.findProperty("KEY_PASSWORD") as String?
            val storePasswordVar = System.getenv("STORE_PASSWORD") ?: project.findProperty("STORE_PASSWORD") as String?

            if (keystorePath != null && file(keystorePath).exists()) {
                storeFile = file(keystorePath)
                storePassword = storePasswordVar ?: ""
                keyAlias = keyAliasVar ?: ""
                keyPassword = keyPasswordVar ?: ""
            } else {
                // Fallback to debug keystore for local dev if release key is not passed
                val debugKeystore = signingConfigs.getByName("debug")
                storeFile = debugKeystore.storeFile
                storePassword = debugKeystore.storePassword
                keyAlias = debugKeystore.keyAlias
                keyPassword = debugKeystore.keyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
