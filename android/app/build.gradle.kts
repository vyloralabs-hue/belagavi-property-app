import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}
val vCode = localProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: flutter.versionCode
val vName = localProperties.getProperty("flutter.versionName") ?: flutter.versionName

android {
    namespace = "com.belagavi.belagavi_property"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.belagavi.belagavi_property"
        minSdk = 24
        targetSdk = 36
        versionCode = 50
        versionName = "1.0.50"
    }

    signingConfigs {
        create("release") {
            val keyAliasProp = System.getenv("KEY_ALIAS") ?: keystoreProperties.getProperty("keyAlias") ?: keystoreProperties.getProperty("keyalias")
            val keyPasswordProp = System.getenv("KEY_PASSWORD") ?: keystoreProperties.getProperty("keyPassword") ?: keystoreProperties.getProperty("keypassword")
            val storeFileProp = System.getenv("STORE_FILE") ?: keystoreProperties.getProperty("storeFile") ?: keystoreProperties.getProperty("storefile") ?: "upload-keystore.jks"
            val storePasswordProp = System.getenv("STORE_PASSWORD") ?: keystoreProperties.getProperty("storePassword") ?: keystoreProperties.getProperty("storepassword")

            val targetFile = file(storeFileProp)
            val fallbackFile = file("../app/$storeFileProp")

            if (keyAliasProp != null && keyPasswordProp != null && storePasswordProp != null && (targetFile.exists() || fallbackFile.exists())) {
                keyAlias = keyAliasProp
                keyPassword = keyPasswordProp
                storeFile = if (targetFile.exists()) targetFile else fallbackFile
                storePassword = storePasswordProp
            }
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.findByName("release")
            if (releaseSigning?.storeFile?.exists() == true) {
                signingConfig = releaseSigning
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("stg") {
            dimension = "env"
            applicationIdSuffix = ".stg"
            versionNameSuffix = "-stg"
        }
        create("prod") {
            dimension = "env"
            versionCode = 50
            versionName = "1.0.50"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
}

