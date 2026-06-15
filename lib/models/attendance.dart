class Attendance {
  final String? id;
  final String date;
  final String period;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime? clientCheckInTime;
  final DateTime? clientCheckOutTime;
  final int totalMinutes;
  final bool autoCheckout;
  final String checkoutType;
  final String? checkOutReason;
  final bool deviceInactiveTimeout;

  Attendance({
    this.id,
    required this.date,
    this.period = 'morning',
    this.checkInTime,
    this.checkOutTime,
    this.clientCheckInTime,
    this.clientCheckOutTime,
    this.totalMinutes = 0,
    this.autoCheckout = false,
    this.checkoutType = 'manual',
    this.checkOutReason,
    this.deviceInactiveTimeout = false,
  });

  static DateTime? _tryParse(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try { return DateTime.parse(value); } catch (_) { return null; }
    }
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? json['_id'],
      date: json['date'] ?? '',
      period: json['period'] ?? 'morning',
      checkInTime: _tryParse(json['checkInTime']),
      checkOutTime: _tryParse(json['checkOutTime']),
      clientCheckInTime: _tryParse(json['clientCheckInTime']),
      clientCheckOutTime: _tryParse(json['clientCheckOutTime']),
      totalMinutes: json['totalMinutes'] ?? 0,
      autoCheckout: json['autoCheckout'] ?? false,
      checkoutType: json['checkoutType'] ?? 'manual',
      checkOutReason: json['checkOutReason'],
      deviceInactiveTimeout: json['deviceInactiveTimeout'] ?? false,
    );
  }
}
