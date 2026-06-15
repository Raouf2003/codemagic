import 'package:geolocator/geolocator.dart';

class MockDetector {
  static bool isMock(Position? pos) {
    if (pos == null) return false;
    if (pos.accuracy < 1.0) return true;
    if (pos.altitude == 0 && pos.altitudeAccuracy == 0) return true;
    return false;
  }

  static double mockConfidence(Position pos, List<Position> recentHistory) {
    double score = 0.0;
    if (pos.accuracy < 2.0) score += 0.3;
    if (pos.altitude == 0) score += 0.2;
    if (pos.altitudeAccuracy == 0) score += 0.2;
    if (pos.speed > 5.0) score += 0.2;
    if (pos.accuracy < 1.0) score += 0.3;
    return score.clamp(0.0, 1.0);
  }

  static bool isHighlySuspicious(Position pos) {
    if (pos.accuracy < 1.0) return true;
    if (pos.altitude == 0 && pos.altitudeAccuracy == 0) return true;
    return false;
  }
}
