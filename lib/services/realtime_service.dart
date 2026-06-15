import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._();
  factory RealtimeService() => _instance;
  RealtimeService._();

  IO.Socket? _socket;
  bool _reconnectExhausted = false;

  final _attendanceController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get onAttendanceUpdated => _attendanceController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (_socket != null) {
      if (_socket!.connected) return;
      if (_reconnectExhausted) {
        _socket!.disconnect();
        _socket = null;
      } else {
        return;
      }
    }
    _reconnectExhausted = false;

    final base = ApiService.baseUrl.replaceAll('/api', '');
    _socket = IO.io(base, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': token},
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 3000,
    });

    _socket!.onConnect((_) {
      _reconnectExhausted = false;
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      _connectionController.add(false);
    });

    _socket!.onConnectError((err) {
      _connectionController.add(false);
    });

    _socket!.on('reconnect_failed', (_) {
      _reconnectExhausted = true;
      _connectionController.add(false);
    });

    _socket!.on('attendance_updated', (data) {
      if (data is Map) {
        _attendanceController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _attendanceController.close();
    _connectionController.close();
  }
}
