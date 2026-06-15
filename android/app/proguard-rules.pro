# Flutter engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Google ML Kit face detection
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# TensorFlow Lite (tflite_flutter)
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.lite.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# App package
-keep class com.attendance.attendance_app.** { *; }

# Mobile scanner (ML Kit barcode scanning)
-keep class com.google.mlkit.vision.barcode.** { *; }

# CameraX
-keep class androidx.camera.** { *; }
