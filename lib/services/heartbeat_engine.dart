import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'location_manager.dart';
import 'mock_detector.dart';

class HeartbeatEngine {
  Timer? _timer;
  int _intervalSeconds = 30;
  String? _currentAttendanceId;
  bool _running = false;
  int _consecutiveFailures = 0;

  final ApiService _api = ApiService();

  bool get isRunning => _running;
  bool get isConnectionLost => _consecutiveFailures > 0;

  VoidCallback? onConnectionLost;
  VoidCallback? onConnectionRestored;
  VoidCallback? onAttendanceEnded;

  void start(String attendanceId) {
    _timer?.cancel();
    _currentAttendanceId = attendanceId;
    _running = true;
    _consecutiveFailures = 0;
    _sendHeartbeat();
    _timer = Timer.periodic(Duration(seconds: _intervalSeconds), (_) {
      if (_running) _sendHeartbeat();
    });
  }

  void setInterval(int seconds) {
    _intervalSeconds = seconds;
    if (_running) {
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: _intervalSeconds), (_) {
        if (_running) _sendHeartbeat();
      });
    }
  }

  Future<void> _sendHeartbeat() async {
    if (_currentAttendanceId == null) return;

    final pos = await LocationManager.getCurrentPosition();
    final isMock = pos != null ? MockDetector.isMock(pos) : false;

    final payload = <String, dynamic>{
      'attendanceId': _currentAttendanceId,
      'lat': pos?.latitude,
      'lng': pos?.longitude,
      'accuracy': pos?.accuracy,
      'isMock': isMock,
      'battery': await _getBatteryLevel(),
      'networkType': await _getNetworkType(),
    };

    try {
      final response = await _api.post('/heartbeat', payload, requiresAuth: true);

      if (_consecutiveFailures > 0) {
        _consecutiveFailures = 0;
        onConnectionRestored?.call();
      }

      if (response['action'] == 'checked_out' || response['action'] == 'no_active_attendance') {
        _running = false;
        _timer?.cancel();
        onAttendanceEnded?.call();
      }
    } catch (e) {
      debugPrint('[Heartbeat] Failed to send: $e');
      final isNetworkError = e is ApiException && e.statusCode == 0;
      if (isNetworkError) {
        _consecutiveFailures++;
        if (_consecutiveFailures == 1) {
          onConnectionLost?.call();
        }
      } else if (_consecutiveFailures > 0) {
        _consecutiveFailures = 0;
        onConnectionRestored?.call();
      }
    }
  }

  static Future<int> _getBatteryLevel() async {
    try {
      return await Battery().batteryLevel;
    } catch (_) {
      return -1;
    }
  }

  static Future<String> _getNetworkType() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.isEmpty) return 'unknown';
      return results.first.name;
    } catch (_) {
      return 'unknown';
    }
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    _currentAttendanceId = null;
  }

  void dispose() => stop();
}
