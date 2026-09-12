plugins {
    id("com.android.application")
    // Built-in Kotlin: Flutter 3.47 ships Kotlin — the kotlin-android
    // plugin and manual jvmTarget are no longer needed.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.localgo.localgo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Built-in Kotlin targets JVM 17 — Java must match (11 vs 17
        // mismatch fails compileDebugKotlin).
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }


    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.localgo.localgo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
