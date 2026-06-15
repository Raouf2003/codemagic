import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class GeofenceState {
  final bool insideGeofence;
  final Position lastKnownPosition;
  final DateTime? lastTransitionTime;

  GeofenceState({
    required this.insideGeofence,
    required this.lastKnownPosition,
    this.lastTransitionTime,
  });
}

class GeofenceService {
  StreamSubscription<Position>? _positionSub;
  Timer? _fallbackTimer;
  Timer? _staleTimer;

  DateTime? _lastPositionUpdateTime;
  DateTime? _lastTransitionTime;
  DateTime? _lastModeSwitch;
  bool _isInside = false;
  bool _isHighFreq = true;
  bool _hasFirstPosition = false;

  Function(GeofenceState state)? onGeofenceChanged;

  static const int _debounceSeconds = 15;

  void startMonitoring(Function(GeofenceState state) callback) {
    onGeofenceChanged = callback;
    _startPositionStream(highFreq: true);
    _startFallbackTimer();
    _startStaleWatchdog();
  }

  LocationSettings _buildSettings({required bool highFreq}) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: highFreq ? 5 : 20,
        intervalDuration: Duration(seconds: highFreq ? 5 : 30),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: 'Attendance System',
          notificationText: 'Tracking location for attendance check-in',
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: highFreq ? 5 : 20,
        pauseLocationUpdatesAutomatically: false,
        activityType: ActivityType.fitness,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: highFreq ? 5 : 20,
    );
  }

  void _startPositionStream({required bool highFreq}) {
    _positionSub?.cancel();
    _isHighFreq = highFreq;

    _positionSub = Geolocator.getPositionStream(
      locationSettings: _buildSettings(highFreq: highFreq),
    ).listen(_onPositionUpdate, onError: (_) {});
  }

  void _onPositionUpdate(Position pos) {
    _lastPositionUpdateTime = DateTime.now();
    _evaluateGeofence(pos);
  }

  void _evaluateGeofence(Position pos) {
    final inside = LocationService.isInsideGeofence(pos.latitude, pos.longitude);
    final distanceToEdge = LocationService.distanceToBoundary(pos.latitude, pos.longitude);
    final isNearBoundary = distanceToEdge.abs() < 30;

    _adjustFrequency(inside: inside, isNearBoundary: isNearBoundary);

    if (!_hasFirstPosition) {
      _hasFirstPosition = true;
      _isInside = inside;
      return;
    }

    final now = DateTime.now();
    if (inside == _isInside) return;

    if (_lastTransitionTime != null &&
        now.difference(_lastTransitionTime!).inSeconds < _debounceSeconds) {
      return;
    }

    _isInside = inside;
    _lastTransitionTime = now;
    onGeofenceChanged?.call(GeofenceState(
      insideGeofence: inside,
      lastKnownPosition: pos,
      lastTransitionTime: now,
    ));
  }

  void _adjustFrequency({required bool inside, required bool isNearBoundary}) {
    final now = DateTime.now();
    if (_lastModeSwitch != null &&
        now.difference(_lastModeSwitch!).inSeconds < _debounceSeconds * 8) {
      return;
    }

    if (!inside || isNearBoundary) {
      if (!_isHighFreq) {
        _lastModeSwitch = now;
        _startPositionStream(highFreq: true);
      }
    } else {
      final stableSeconds = _lastTransitionTime == null
          ? 0
          : now.difference(_lastTransitionTime!).inSeconds;
      if (_isHighFreq && stableSeconds > 60) {
        _lastModeSwitch = now;
        _startPositionStream(highFreq: false);
      }
    }
  }

  Future<void> _tryFetchPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _onPositionUpdate(pos);
      return;
    } catch (_) {}

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );
      _onPositionUpdate(pos);
    } catch (_) {}
  }

  void _startFallbackTimer() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _tryFetchPosition();
    });
  }

  void _startStaleWatchdog() {
    _staleTimer?.cancel();
    _staleTimer = Timer.periodic(const Duration(seconds: 90), (_) async {
      if (_lastPositionUpdateTime == null) return;
      if (DateTime.now().difference(_lastPositionUpdateTime!).inSeconds > 90) {
        await _tryFetchPosition();
      }
    });
  }

  void stopMonitoring() {
    _positionSub?.cancel();
    _fallbackTimer?.cancel();
    _staleTimer?.cancel();
    _positionSub = null;
    _fallbackTimer = null;
    _staleTimer = null;
    _lastPositionUpdateTime = null;
    _lastTransitionTime = null;
    _lastModeSwitch = null;
    _isInside = false;
    _isHighFreq = true;
    _hasFirstPosition = false;
    onGeofenceChanged = null;
  }

  void dispose() => stopMonitoring();
}
