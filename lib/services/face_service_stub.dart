import 'package:flutter/foundation.dart';

class FaceService {
  static final FaceService instance = FaceService._();
  FaceService._();

  Future<void> initialize() async {
    debugPrint('[FaceService] Web stub — face recognition not available on web.');
  }

  Future<dynamic> extractDescriptorFromFile(dynamic file) async {
    return 'Face recognition is not available on the web platform. Please use the mobile app.';
  }

  void dispose() {}
}
