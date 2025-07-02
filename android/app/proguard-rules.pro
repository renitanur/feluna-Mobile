# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
# Prevent R8 from removing TensorFlow Lite GPU Delegate classes
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
