import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../models/employee_report.dart';
import '../services/api_service.dart';

class EmployeeReportProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<AttendanceRecord> _records = [];
  Map<String, dynamic>? _summary;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoadingHistory = false;
  String? _historyError;

  List<EmployeeReport> _reports = [];
  bool _isLoadingReports = false;
  String? _reportsError;

  List<AttendanceRecord> get records => _records;
  Map<String, dynamic>? get summary => _summary;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;
  List<EmployeeReport> get reports => _reports;
  bool get isLoadingReports => _isLoadingReports;
  String? get reportsError => _reportsError;

  Future<void> loadHistory({int? month, int? year}) async {
    if (month != null) _selectedMonth = month;
    if (year != null) _selectedYear = year;

    _isLoadingHistory = true;
    notifyListeners();

    try {
      final response = await _api.get(
        '/attendance-history?month=$_selectedMonth&year=$_selectedYear',
      );
      final list = (response['records'] as List?) ?? [];
      _records = list.map((r) => AttendanceRecord.fromJson(r)).toList();
      _summary = response['summary'];
      _isLoadingHistory = false;
      notifyListeners();
    } catch (e) {
      _historyError = e.toString().replaceFirst('Exception: ', '');
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadReports() async {
    _isLoadingReports = true;
    notifyListeners();

    try {
      final response = await _api.get('/my-reports');
      final list = (response['reports'] as List?) ?? [];
      _reports = list.map((r) => EmployeeReport.fromJson(r)).toList();
      _isLoadingReports = false;
      notifyListeners();
    } catch (e) {
      _reportsError = e.toString().replaceFirst('Exception: ', '');
      _isLoadingReports = false;
      notifyListeners();
    }
  }

  Future<String?> createReport(String type, String description, {String? photo}) async {
    try {
      final body = <String, dynamic>{
        'type': type,
        'description': description,
      };
      if (photo != null) body['photo'] = photo;

      final response = await _api.post('/reports', body, requiresAuth: true);
      if (response.containsKey('report')) {
        await loadReports();
        return null;
      }
      return response['message'] ?? 'Failed to create report';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
