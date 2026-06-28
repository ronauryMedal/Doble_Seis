# --- ML Kit / escáner QR ---
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn com.google.android.gms.**

# --- AndroidX Startup / WorkManager / Room (usados por AdMob) ---
# Evita que R8 elimine clases que estos componentes necesitan en runtime
# (causa: "Failed to create an instance of androidx.work.impl.WorkDatabase").
-keep class androidx.startup.** { *; }
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker {
    <init>(...);
}
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Entity class * { *; }
-dontwarn androidx.work.**
-dontwarn androidx.room.**

# --- Play Core (deferred components, requerido por Flutter en release) ---
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
