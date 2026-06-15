import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart' show ApiService, ApiException;
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Employee? _employee;
  bool _isLoading = false;
  String? _error;
  String? _errorCode;

  Employee? get employee => _employee;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorCode => _errorCode;
  bool get isLoggedIn => _employee != null;
  bool get isAdmin => _employee?.role == 'admin';

  Future<bool> login(String employeeNumber, String password) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      final response = await _api.post('/login', {
        'employeeNumber': employeeNumber,
        'password': password,
      });

      if (response.containsKey('token')) {
        await _api.saveToken(response['token']);
        _employee = Employee.fromJson(response['employee']);
        await NotificationService().registerToken();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 0) {
        _error = 'no_internet';
      } else if (e is ApiException) {
        _error = e.message;
        _errorCode = e.code;
      } else {
        _error = 'Login failed';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.deleteToken();
    _employee = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _api.getToken();
    if (token == null) return false;

    try {
      final response = await _api.get('/status');
      if (response.containsKey('employee')) {
        _employee = Employee.fromJson(response['employee']);
        notifyListeners();
        return true;
      }
    } catch (e) {
      await _api.deleteToken();
    }
    return false;
  }
}
