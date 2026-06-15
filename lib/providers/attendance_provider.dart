import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/api_service.dart' show ApiService, ApiException;
import '../services/location_service.dart';
import '../services/geofence_service.dart';
import '../services/realtime_service.dart';
import '../services/presence_manager.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final GeofenceService _geofence = GeofenceService();
  final LocationService _locationService = LocationService();
  final RealtimeService _realtime = RealtimeService();
  final PresenceManager _presence = PresenceManager();

  StreamSubscription<Map<String, dynamic>>? _attSub;
  StreamSubscription<bool>? _connSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _reconnectBackoff;
  bool _realtimeReady = false;

  Attendance? _morningAttendance;
  Attendance? _eveningAttendance;
  String _currentPeriod = 'morning';
  bool _isLoading = false;
  String? _error;
  Timer? _timer;
  Timer? _pollTimer;
  Duration _elapsed = Duration.zero;
  String _activeTimerPeriod = 'morning';

  bool _isInsideGeofence = true;
  bool _isGeofenceChecking = false;
  bool _connectionLost = false;
  double? _currentLat;
  double? _currentLng;

  Attendance? get morningAttendance => _morningAttendance;
  Attendance? get eveningAttendance => _eveningAttendance;
  String get currentPeriod => _currentPeriod;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Duration get elapsed => _elapsed;
  bool get isInsideGeofence => _isInsideGeofence;
  bool get isGeofenceChecking => _isGeofenceChecking;
  bool get connectionLost => _connectionLost;
  double? get currentLat => _currentLat;
  double? get currentLng => _currentLng;

  String get morningStatus {
    if (_morningAttendance == null) return 'not_started';
    if (_morningAttendance!.checkInTime != null && _morningAttendance!.checkOutTime == null) return 'working';
    if (_morningAttendance!.checkInTime != null && _morningAttendance!.checkOutTime != null) return 'finished';
    return 'not_started';
  }

  String get eveningStatus {
    if (_eveningAttendance == null) return 'not_started';
    if (_eveningAttendance!.checkInTime != null && _eveningAttendance!.checkOutTime == null) return 'working';
    if (_eveningAttendance!.checkInTime != null && _eveningAttendance!.checkOutTime != null) return 'finished';
    return 'not_started';
  }

  bool get isAnyWorking => morningStatus == 'working' || eveningStatus == 'working';

  String? get workingPeriod {
    if (morningStatus == 'working') return 'morning';
    if (eveningStatus == 'working') return 'evening';
    return null;
  }

  Future<void> initRealtime() async {
    if (_realtimeReady) return;
    _realtimeReady = true;

    final token = await _api.getToken();
    if (token == null) return;

    _realtime.connect(token);

    _attSub = _realtime.onAttendanceUpdated.listen((data) {
      if (data['employeeId'] != null && data['employeeId'].toString() == _apiEmployeeId()) {
        loadStatus();
      }
    });

    _connSub = _realtime.onConnectionChanged.listen((connected) {
      if (connected) {
        loadStatus();
      }
    });
  }

  Future<void> loadStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/status');
      _currentPeriod = response['currentPeriod'] ?? 'morning';

      if (response['morning']?['attendance'] != null) {
        _morningAttendance = Attendance.fromJson(response['morning']['attendance']);
      } else {
        _morningAttendance = null;
      }

      if (response['evening']?['attendance'] != null) {
        _eveningAttendance = Attendance.fromJson(response['evening']['attendance']);
      } else {
        _eveningAttendance = null;
      }

      if (response['geofence'] != null) {
        final gf = response['geofence'];
        if (gf['companyLocation'] != null) {
          LocationService.setGeofence(
            (gf['companyLocation']['lat'] as num).toDouble(),
            (gf['companyLocation']['lng'] as num).toDouble(),
            (gf['allowedRadius'] as num).toDouble(),
          );
        }
      }

      if (response['shifts'] != null) {
        _morningStart = response['shifts']['morningStart'] ?? '08:00';
        _morningEnd = response['shifts']['morningEnd'] ?? '12:00';
        _eveningStart = response['shifts']['eveningStart'] ?? '13:00';
        _eveningEnd = response['shifts']['eveningEnd'] ?? '16:00';
      }

      if (response['employee'] != null && response['employee']['id'] != null) {
        _cachedEmployeeId = response['employee']['id'].toString();
      }

      _manageTimer();
      _updateGeofenceMonitoring();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateGeofenceMonitoring() {
    if (isAnyWorking) {
      startGeofenceMonitoring();
    } else {
      stopGeofenceMonitoring();
    }
  }

  void startGeofenceMonitoring() {
    final period = workingPeriod;
    final attendanceId = _getCurrentAttendanceId();
    if (attendanceId != null && period != null) {
      _presence.start(
        attendanceId: attendanceId,
        period: period,
      );
      _presence.onGeofenceChanged = () {
        _isInsideGeofence = _presence.isInsideGeofence;
        notifyListeners();
      };
      _presence.onConnectionLost = () {
        _connectionLost = true;
        notifyListeners();
      };
      _presence.onConnectionRestored = () {
        _connectionLost = false;
        notifyListeners();
      };
      _presence.onAttendanceEnded = () {
        _connectionLost = false;
        loadStatus();
      };
      _connectivitySub?.cancel();
      _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
        if (!_connectionLost) return;
        final hasInternet = results.any((r) =>
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.ethernet);
        if (hasInternet) {
          _connectionLost = false;
          notifyListeners();
        }
      });
    }
  }

  Future<void> stopGeofenceMonitoring() async {
    await _presence.stop();
    _geofence.stopMonitoring();
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _connectionLost = false;
  }

  String? _getCurrentAttendanceId() {
    if (morningStatus == 'working' && _morningAttendance != null) {
      return _morningAttendance!.id;
    }
    if (eveningStatus == 'working' && _eveningAttendance != null) {
      return _eveningAttendance!.id;
    }
    return null;
  }

  Future<String?> checkGeofence() async {
    _isGeofenceChecking = true;
    notifyListeners();

    try {
      final pos = await _locationService.getCurrentPosition();
      if (pos == null) {
        _isGeofenceChecking = false;
        notifyListeners();
        return 'GPS location is not available. Please enable location services.';
      }

      _currentLat = pos.latitude;
      _currentLng = pos.longitude;

      if (!LocationService.isInsideGeofence(pos.latitude, pos.longitude)) {
        _isInsideGeofence = false;
        _isGeofenceChecking = false;
        notifyListeners();
        return 'You are outside the allowed area';
      }

      _isInsideGeofence = true;
      _isGeofenceChecking = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isGeofenceChecking = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> checkIn(String period) async {
    _error = null;

    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    if (period == 'morning') {
      final parts = _morningStart.split(':');
      final startMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final endParts = _morningEnd.split(':');
      final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      if (nowMin < startMin || nowMin >= endMin) {
        return 'Morning check-in allowed only $_morningStart - $_morningEnd';
      }
    }
    if (period == 'evening') {
      final parts = _eveningStart.split(':');
      final startMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final endParts = _eveningEnd.split(':');
      final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      if (nowMin < startMin || nowMin >= endMin) {
        return 'Evening check-in allowed only $_eveningStart - $_eveningEnd';
      }
    }

    _isLoading = true;
    notifyListeners();

    final clientEventTime = DateTime.now().toUtc().toIso8601String();

    try {
      final response = await _api.post('/checkin', {
        'period': period,
        'lat': _currentLat,
        'lng': _currentLng,
        'clientEventTime': clientEventTime,
      }, requiresAuth: true);

      if (response.containsKey('attendance')) {
        final att = Attendance.fromJson(response['attendance']);
        if (period == 'morning') {
          _morningAttendance = att;
        } else {
          _eveningAttendance = att;
        }
        _manageTimer();
        _updateGeofenceMonitoring();
        _isLoading = false;
        notifyListeners();
        return null;
      } else {
        _isLoading = false;
        notifyListeners();
        return response['message'] ?? 'Check-in failed';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e is ApiException && e.statusCode == 0) return 'no_internet';
      return 'Check-in failed: ${e.toString().replaceFirst("Exception: ", "")}';
    }
  }

  Future<String?> checkOut(String period) async {
    _error = null;

    final clientEventTime = DateTime.now().toUtc().toIso8601String();
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post('/checkout', {
        'period': period,
        'clientEventTime': clientEventTime,
      }, requiresAuth: true);

      if (response.containsKey('attendance')) {
        final att = Attendance.fromJson(response['attendance']);
        if (period == 'morning') {
          _morningAttendance = att;
        } else {
          _eveningAttendance = att;
        }
        _manageTimer();
        _updateGeofenceMonitoring();
        _isLoading = false;
        notifyListeners();
        return null;
      } else {
        _isLoading = false;
        notifyListeners();
        return response['message'] ?? 'Check-out failed';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e is ApiException && e.statusCode == 0) return 'no_internet';
      return 'Check-out failed: ${e.toString().replaceFirst("Exception: ", "")}';
    }
  }

  void _manageTimer() {
    _timer?.cancel();
    _pollTimer?.cancel();
    _elapsed = Duration.zero;

    if (morningStatus == 'working' && _morningAttendance?.checkInTime != null) {
      _activeTimerPeriod = 'morning';
      _startTimer(_morningAttendance!.checkInTime!);
    } else if (eveningStatus == 'working' && _eveningAttendance?.checkInTime != null) {
      _activeTimerPeriod = 'evening';
      _startTimer(_eveningAttendance!.checkInTime!);
    }
  }

  void _startTimer(DateTime checkInTime) {
    _timer?.cancel();
    _pollTimer?.cancel();
    _elapsed = DateTime.now().difference(checkInTime.toLocal());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(checkInTime.toLocal());
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadStatus();
    });
  }

  String getElapsedFormatted() {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get timerPeriod => _activeTimerPeriod;

  String _morningStart = '08:00';
  String _morningEnd = '12:00';
  String _eveningStart = '13:00';
  String _eveningEnd = '16:00';

  String get morningStart => _morningStart;
  String get morningEnd => _morningEnd;
  String get eveningStart => _eveningStart;
  String get eveningEnd => _eveningEnd;

  String get morningTimeRange => '$_morningStart - $_morningEnd';
  String get eveningTimeRange => '$_eveningStart - $_eveningEnd';

  String? _cachedEmployeeId;
  String _apiEmployeeId() {
    if (_cachedEmployeeId != null) return _cachedEmployeeId!;
    return '';
  }

  void cacheEmployeeId(String id) {
    _cachedEmployeeId = id;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    _presence.dispose();
    _geofence.dispose();
    _attSub?.cancel();
    _connSub?.cancel();
    _connectivitySub?.cancel();
    _reconnectBackoff?.cancel();
    super.dispose();
  }
}
