import java.util.Properties

plugins {
    id("com.android.application")
    // Flutter Gradle eklentisi, Android ve Kotlin Gradle eklentilerinden sonra uygulanmalıdır.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.renkli.renkli_ogrenme"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "30.0.15729638"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Kendinize ait benzersiz uygulama kimliğini belirtin (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.renkli.renkli_ogrenme"
        // Aşağıdaki değerleri uygulamanızın gereksinimlerine göre güncelleyebilirsiniz.
        // Ayrıntılı bilgi: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val signingProperties = Properties()
    val signingPropertiesFile = rootProject.file("key.properties")
    val hasReleaseSigning = signingPropertiesFile.isFile
    if (hasReleaseSigning) {
        signingPropertiesFile.inputStream().use(signingProperties::load)
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = signingProperties.getProperty("keyAlias")
                keyPassword = signingProperties.getProperty("keyPassword")
                storeFile = rootProject.file(signingProperties.getProperty("storeFile"))
                storePassword = signingProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

gradle.taskGraph.whenReady {
    if (!rootProject.file("key.properties").isFile && allTasks.any { task ->
            task.name.contains("Release", ignoreCase = true)
        }) {
        throw GradleException(
            "Release signing is not configured. Copy android/key.properties.example " +
                "to android/key.properties and provide your own keystore values.",
        )
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
