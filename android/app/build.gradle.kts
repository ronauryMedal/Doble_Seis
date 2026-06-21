plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.domino.score.domino_score"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.domino.score.domino_score"
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
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    applicationVariants.configureEach {
        val variant = this
        outputs.configureEach {
            val suffix = if (variant.buildType.name == "release") "" else "-${variant.buildType.name}"
            val apkName = "Doble-Seis-v${variant.versionName}$suffix"
            (this as com.android.build.gradle.internal.api.ApkVariantOutputImpl)
                .outputFileName = "$apkName.apk"
        }
        if (variant.buildType.name == "release") {
            variant.assembleProvider.configure {
                doLast {
                    val apk = variant.outputs.first().outputFile
                    val flutterApkDir = file("${rootProject.projectDir}/../build/app/outputs/flutter-apk")
                    flutterApkDir.mkdirs()
                    apk.copyTo(
                        file("${flutterApkDir}/Doble-Seis-v${variant.versionName}.apk"),
                        overwrite = true,
                    )
                }
            }
        }
    }
}

dependencies {
    // ML Kit embebido — evita fallos del escáner QR en APK release.
    implementation("com.google.mlkit:barcode-scanning:17.3.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
