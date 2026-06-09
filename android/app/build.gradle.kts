import java.util.Properties
import java.io.FileInputStream

val keyStoreProperties = Properties()
val keyStorePropertiesFile = rootProject.file("key.properties")
if (keyStorePropertiesFile.exists()) {
    keyStoreProperties.load(FileInputStream(keyStorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21"
}

android {
    namespace = "com.sandeep.stream_check"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        compose = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.sandeep.stream_check"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Custom release signing config based on key.properties
        create("release") {
            keyAlias = keyStoreProperties["keyAlias"] as String?
            keyPassword = keyStoreProperties["keyPassword"] as String?
            storeFile = keyStoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keyStoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }

        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.glance:glance") {
        version { strictly("1.1.1") }
    }
    implementation("androidx.glance:glance-appwidget") {
        version { strictly("1.1.1") }
    }
    implementation("androidx.datastore:datastore-preferences:1.1.1")
}