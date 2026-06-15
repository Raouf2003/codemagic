import 'package:flutter/material.dart';
import 'heartbeat_engine.dart';
import 'geofence_service.dart';

class PresenceManager {
  final HeartbeatEngine _heartbeat = HeartbeatEngine();
  final GeofenceService _geofence = GeofenceService();

  bool _isInsideGeofence = true;
  bool _isMonitoring = false;
  String? _activeAttendanceId;

  bool get isInsideGeofence => _isInsideGeofence;
  bool get isMonitoring => _isMonitoring;
  String? get activeAttendanceId => _activeAttendanceId;
  bool get isConnectionLost => _heartbeat.isConnectionLost;

  VoidCallback? onGeofenceChanged;
  VoidCallback? onConnectionLost;
  VoidCallback? onConnectionRestored;
  VoidCallback? onAttendanceEnded;

  Future<void> start({
    required String attendanceId,
    required String period,
  }) async {
    _activeAttendanceId = attendanceId;
    _isMonitoring = true;

    _heartbeat.onConnectionLost = () => onConnectionLost?.call();
    _heartbeat.onConnectionRestored = () => onConnectionRestored?.call();
    _heartbeat.onAttendanceEnded = () => onAttendanceEnded?.call();
    _heartbeat.start(attendanceId);

    _geofence.startMonitoring((GeofenceState state) {
      _isInsideGeofence = state.insideGeofence;
      onGeofenceChanged?.call();
    });
  }

  Future<void> stop() async {
    _isMonitoring = false;
    _activeAttendanceId = null;
    _heartbeat.stop();
    _geofence.stopMonitoring();
  }

  void dispose() {
    stop();
  }
}
