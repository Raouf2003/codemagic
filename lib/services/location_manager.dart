import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationManager {
  static int _gpsLostSeconds = 0;
  static Timer? _degradationTimer;
  static Function()? onGpsLostTimeout;
  static Function()? onGpsRecovered;
  static bool _monitoring = false;

  static void startDegradationMonitor({Function()? onTimeout, Function()? onRecovered}) {
    if (_monitoring) return;
    _monitoring = true;
    onGpsLostTimeout = onTimeout;
    onGpsRecovered = onRecovered;
    _gpsLostSeconds = 0;

    _degradationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _gpsLostSeconds += 10;
        if (_gpsLostSeconds >= 300) {
          onGpsLostTimeout?.call();
          _gpsLostSeconds = 0;
        }
      } else {
        if (_gpsLostSeconds > 0) {
          _gpsLostSeconds = 0;
          onGpsRecovered?.call();
        }
      }
    });
  }

  static void resetGpsLostCounter() {
    _gpsLostSeconds = 0;
  }

  static int get gpsLostSeconds => _gpsLostSeconds;

  static Future<Position?> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _gpsLostSeconds = 0;
      return pos;
    } catch (_) {}

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );
      _gpsLostSeconds = 0;
      return pos;
    } catch (_) {}

    return null;
  }

  static void stopDegradationMonitor() {
    _monitoring = false;
    _degradationTimer?.cancel();
    _degradationTimer = null;
    _gpsLostSeconds = 0;
    onGpsLostTimeout = null;
    onGpsRecovered = null;
  }
}
