const int _algeriaUtcOffsetHours = 1;

class AttendanceRecord {
  final String id;
  final String date;
  final String period;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int totalMinutes;
  final bool autoCheckout;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.period,
    this.checkInTime,
    this.checkOutTime,
    this.totalMinutes = 0,
    this.autoCheckout = false,
  });

  static DateTime? _tryParse(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try { return DateTime.parse(value); } catch (_) { return null; }
    }
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? json['_id'] ?? '',
      date: json['date'] ?? '',
      period: json['period'] ?? '',
      checkInTime: _tryParse(json['checkInTime']),
      checkOutTime: _tryParse(json['checkOutTime']),
      totalMinutes: json['totalMinutes'] ?? 0,
      autoCheckout: json['autoCheckout'] ?? false,
    );
  }

  String get checkInStr {
    if (checkInTime == null) return '-';
    final algeria = checkInTime!.add(const Duration(hours: _algeriaUtcOffsetHours));
    final h = algeria.hour.toString().padLeft(2, '0');
    final m = algeria.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get checkOutStr {
    if (checkOutTime == null) return '-';
    final algeria = checkOutTime!.add(const Duration(hours: _algeriaUtcOffsetHours));
    final h = algeria.hour.toString().padLeft(2, '0');
    final m = algeria.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get totalStr {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }
}
