# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }

# Prevent obfuscation of MainActivity & GeneratedPluginRegistrant
-keep class dev.codedd.chat_stats.MainActivity { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Google Mobile Ads SDK (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# SQFlite plugin
-keep class com.tekartik.sqflite.** { *; }

# Receive Sharing Intent plugin
-keep class com.kasem.receive_sharing_intent.** { *; }

# AndroidX WorkManager, Room Database & Startup (Fixes WorkDatabase_Impl reflection crash in Release)
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.impl.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.startup.** { *; }
-dontwarn androidx.work.**
-dontwarn androidx.room.**

# Suppress warnings for optional Play Core deferred components
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Preserve native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve synthetic accessor methods
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Keep serializable & enum names
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
