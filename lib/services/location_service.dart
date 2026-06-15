import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static double _companyLat = 35.219445;
  static double _companyLng = 4.204832;
  static double _geofenceRadiusMeters = 50;

  static double get companyLat => _companyLat;
  static double get companyLng => _companyLng;
  static double get geofenceRadiusMeters => _geofenceRadiusMeters;

  static void setGeofence(double lat, double lng, double radius) {
    _companyLat = lat;
    _companyLng = lng;
    _geofenceRadiusMeters = radius;
  }

  static void resetGeofence() {
    _companyLat = 35.219445;
    _companyLng = 4.204832;
    _geofenceRadiusMeters = 50;
  }

  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {}

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (_) {}

    return null;
  }

  static double haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = _sinSquared(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * _sinSquared(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static bool isInsideGeofence(double lat, double lng) {
    final distance = haversineDistance(lat, lng, _companyLat, _companyLng);
    return distance <= _geofenceRadiusMeters;
  }

  /// Returns distance to geofence boundary in meters.
  /// Positive = inside (distance remaining before exit).
  /// Negative = outside (distance past the boundary).
  /// Zero = exactly on boundary.
  static double distanceToBoundary(double lat, double lng) {
    final distance = haversineDistance(lat, lng, _companyLat, _companyLng);
    return _geofenceRadiusMeters - distance;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  static double _sinSquared(double x) {
    final s = sin(x);
    return s * s;
  }
}
