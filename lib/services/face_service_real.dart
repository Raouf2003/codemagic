import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceService {
  static final FaceService instance = FaceService._();
  FaceService._();

  Interpreter? _interpreter;
  bool _modelLoadAttempted = false;
  String? _initError;

  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableContours: false,
      enableTracking: false,
      minFaceSize: 0.1,
    ),
  );

  Future<void> initialize() async {
    if (_modelLoadAttempted && _interpreter != null) return;
    _modelLoadAttempted = true;
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/mobilefacenet.tflite',
        options: InterpreterOptions()..threads = 2,
      );
      debugPrint('[FaceService] MobileFaceNet model loaded.');
    } catch (e) {
      _initError = e.toString();
      debugPrint('[FaceService] Failed to load TFLite model: $e');
    }
  }

  bool get isReady => _interpreter != null;

  /// Main pipeline: detect → align → crop → normalize → infer → L2-normalize
  Future<dynamic> extractDescriptorFromFile(XFile file) async {
    try {
      if (!_modelLoadAttempted || _interpreter == null) await initialize();
      if (_interpreter == null) {
        return 'Model load failed: ${_initError ?? "Unknown error"}';
      }

      final bytes = await file.readAsBytes();

      InputImage inputImage;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final rawImage = img.decodeImage(bytes);
        if (rawImage == null) return 'Failed to decode raw image';

        debugPrint('[FaceService] Input: ${rawImage.width}x${rawImage.height}');

        final bgraBytes = Uint8List(rawImage.width * rawImage.height * 4);
        for (int y = 0; y < rawImage.height; y++) {
          for (int x = 0; x < rawImage.width; x++) {
            final p = rawImage.getPixel(x, y);
            final offset = (y * rawImage.width + x) * 4;
            bgraBytes[offset] = p.b.toInt();
            bgraBytes[offset + 1] = p.g.toInt();
            bgraBytes[offset + 2] = p.r.toInt();
            bgraBytes[offset + 3] = 255;
          }
        }

        inputImage = InputImage.fromBytes(
          bytes: bgraBytes,
          metadata: InputImageMetadata(
            size: Size(rawImage.width.toDouble(), rawImage.height.toDouble()),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.bgra8888,
            bytesPerRow: rawImage.width * 4,
          ),
        );
      } else {
        inputImage = InputImage.fromFilePath(file.path);
      }
      final faces = await _detector.processImage(inputImage);
      if (faces.isEmpty) {
        debugPrint('[FaceService] No faces detected');
        return 'No face detected. Please look directly at the camera.';
      }

      final face = faces.reduce((a, b) =>
          (a.boundingBox.width * a.boundingBox.height) >
                  (b.boundingBox.width * b.boundingBox.height)
              ? a
              : b);

      debugPrint('[FaceService] Face bbox: '
          '${face.boundingBox.left.toStringAsFixed(0)},'
          '${face.boundingBox.top.toStringAsFixed(0)} '
          '${face.boundingBox.width.toStringAsFixed(0)}x'
          '${face.boundingBox.height.toStringAsFixed(0)}');

      Map<FaceLandmarkType, Point<double>> landmarks = {};
      for (final t in FaceLandmarkType.values) {
        final lm = face.landmarks[t];
        if (lm != null) {
          landmarks[t] = Point<double>(lm.position.x.toDouble(), lm.position.y.toDouble());
        }
      }

      if (landmarks.containsKey(FaceLandmarkType.leftEye) &&
          landmarks.containsKey(FaceLandmarkType.rightEye)) {
        debugPrint('[FaceService] Landmarks: leftEye='
            '(${landmarks[FaceLandmarkType.leftEye]!.x.toStringAsFixed(0)},'
            '${landmarks[FaceLandmarkType.leftEye]!.y.toStringAsFixed(0)}) '
            'rightEye='
            '(${landmarks[FaceLandmarkType.rightEye]!.x.toStringAsFixed(0)},'
            '${landmarks[FaceLandmarkType.rightEye]!.y.toStringAsFixed(0)})');
      } else {
        debugPrint('[FaceService] No eye landmarks — skipping alignment');
      }

      final aligned = _alignAndCrop(rawImage, face.boundingBox, landmarks);
      if (aligned == null) {
        debugPrint('[FaceService] Alignment/crop failed, falling back to basic crop');
        final fallback = _cropAndResize(rawImage, face.boundingBox);
        if (fallback == null) return 'Failed to crop and resize face';
        final desc = _runInference(fallback);
        if (desc == null) return 'TFLite inference returned null';
        final l2Normed = _l2Normalize(desc);
        debugPrint('[FaceService] Descriptor: ${l2Normed.length}-d');
        return l2Normed;
      }

      final desc = _runInference(aligned);
      if (desc == null) return 'TFLite inference returned null';

      final l2Normed = _l2Normalize(desc);
      debugPrint('[FaceService] Descriptor: ${l2Normed.length}-d, '
          'first 5: ${l2Normed.take(5).map((v) => v.toStringAsFixed(4)).join(", ")}');
      return l2Normed;
    } catch (e) {
      debugPrint('[FaceService] Error: $e');
      return 'Face processing error: $e';
    }
  }

  /// Align face using eye landmarks, then crop with 25% margin and resize to 112x112.
  img.Image? _alignAndCrop(
      img.Image src, Rect bbox, Map<FaceLandmarkType, Point<double>> landmarks) {
    try {
      final srcW = src.width;
      final srcH = src.height;

      // Default to center of bounding box if landmarks unavailable
      double cx = bbox.left + bbox.width / 2;
      double cy = bbox.top + bbox.height / 2;
      double angle = 0;

      if (landmarks.containsKey(FaceLandmarkType.leftEye) &&
          landmarks.containsKey(FaceLandmarkType.rightEye)) {
        final lx = landmarks[FaceLandmarkType.leftEye]!.x;
        final ly = landmarks[FaceLandmarkType.leftEye]!.y;
        final rx = landmarks[FaceLandmarkType.rightEye]!.x;
        final ry = landmarks[FaceLandmarkType.rightEye]!.y;

        cx = (lx + rx) / 2;
        cy = (ly + ry) / 2;
        angle = atan2(ry - ly, rx - lx);

        debugPrint('[FaceService] Alignment: eyeCenter=(${cx.toStringAsFixed(0)},'
            '${cy.toStringAsFixed(0)}) angle=${(angle * 180 / pi).toStringAsFixed(1)}deg');
      }

      final faceSize = max(bbox.width, bbox.height);
      final margin = faceSize * 0.25;
      final cropSide = (faceSize + margin * 2).toInt();

      // Apply rotation around eye center
      img.Image rotated;
      if (angle.abs() > 0.02) {
        rotated = img.copyRotate(src, angle: -(angle * 180 / pi));
        debugPrint('[FaceService] Rotated image by ${(angle * 180 / pi).toStringAsFixed(1)}deg');
      } else {
        rotated = src;
      }

      // Crop the rotated image centered on face
      final cropX = (cx - cropSide / 2).clamp(0.0, (srcW - 1).toDouble()).toInt();
      final cropY = (cy - cropSide / 2).clamp(0.0, (srcH - 1).toDouble()).toInt();
      final cropW = min(cropSide, srcW - cropX);
      final cropH = min(cropSide, srcH - cropY);

      final cropped = img.copyCrop(rotated, x: cropX, y: cropY, width: cropW, height: cropH);
      final resized = img.copyResize(cropped, width: 112, height: 112);

      debugPrint('[FaceService] Crop: ${cropW}x$cropH at ($cropX,$cropY) → 112x112');
      return resized;
    } catch (e) {
      debugPrint('[FaceService] _alignAndCrop error: $e');
      return null;
    }
  }

  /// Fallback crop without alignment.
  img.Image? _cropAndResize(img.Image src, Rect bbox) {
    try {
      final srcW = src.width;
      final srcH = src.height;
      final faceW = bbox.width;
      final faceH = bbox.height;
      final faceCx = bbox.left + faceW / 2;
      final faceCy = bbox.top + faceH / 2;
      final expandRatio = 0.25;
      final side = max(faceW, faceH) * (1.0 + expandRatio * 2);
      final cropSize = side.toInt();
      final cropX = (faceCx - cropSize / 2).clamp(0.0, (srcW - 1).toDouble()).toInt();
      final cropY = (faceCy - cropSize / 2).clamp(0.0, (srcH - 1).toDouble()).toInt();
      final cropW = min(cropSize, srcW - cropX);
      final cropH = min(cropSize, srcH - cropY);
      final cropped = img.copyCrop(src, x: cropX, y: cropY, width: cropW, height: cropH);
      final resized = img.copyResize(cropped, width: 112, height: 112);
      return resized;
    } catch (e) {
      debugPrint('[FaceService] _cropAndResize error: $e');
      return null;
    }
  }

  List<double>? _runInference(img.Image face112) {
    final interp = _interpreter;
    if (interp == null) return null;

    final inputShape = interp.getInputTensor(0).shape;
    final outputShape = interp.getOutputTensor(0).shape;

    final input = List.generate(
      1,
      (_) => List.generate(
        112,
        (y) => List.generate(
          112,
          (x) => List.generate(3, (c) {
            final p = face112.getPixel(x, y);
            final v = c == 0 ? p.r : c == 1 ? p.g : p.b;
            return (v.toDouble() - 127.5) / 127.5;
          }),
        ),
      ),
    );

    try {
      int outSize = outputShape.isNotEmpty && outputShape.last > 0 ? outputShape.last : 128;
      final output = [List.filled(outSize, 0.0)];
      interp.run(input, output);
      final raw = List<double>.from(output[0]);
      debugPrint('[FaceService] TFLite: ${raw.length}-d, '
          'first 5: ${raw.take(5).map((v) => v.toStringAsFixed(4)).join(", ")}');
      return raw;
    } catch (e) {
      throw Exception('TFLite failed. In: $inputShape, Out: $outputShape. $e');
    }
  }

  List<double> _l2Normalize(List<double> v) {
    double sumSq = 0;
    for (final x in v) {
      sumSq += x * x;
    }
    final norm = sqrt(sumSq);
    if (norm < 1e-10) return v;
    return v.map((x) => x / norm).toList();
  }

  /// Cosine similarity between two L2-normalized vectors.
  /// Returns 1.0 for identical, -1.0 for opposite, 0.0 for orthogonal.
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return -1.0;
    double dot = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  /// Euclidean distance (kept for backward compat).
  static double distance(List<double> a, List<double> b) {
    if (a.length != b.length) return double.infinity;
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += pow(a[i] - b[i], 2).toDouble();
    }
    return sqrt(sum);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _modelLoadAttempted = false;
    _detector.close();
  }
}
