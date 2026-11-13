# R8 rules for PhoneLM.
#
# The native inference plugins are reached through JNI: llama.cpp and
# stable-diffusion.cpp look up classes and methods by name at runtime
# (System.loadLibrary + FindClass), so shrinking them breaks symbol
# resolution even when Dart-side code paths look unused.

# JNI callbacks in the llama.cpp engine plugin
-keep class com.write4me.llama_flutter_android.** { *; }

# JNI callbacks in the stable-diffusion engine plugin
-keep class com.example.sd_flutter_android.** { *; }

# LiteRT-LM runtime (loaded via NativeLibraryLoader)
-keep class com.google.ai.edge.litertlm.** { *; }

# Entry point registered with the Flutter engine
-keep class com.phonellm.app.** { *; }

# Kotlin metadata warnings from prebuilt AARs
-dontwarn kotlin.Metadata
-dontwarn org.jetbrains.annotations.**
