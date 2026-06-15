class EmployeeReport {
  final String id;
  final String type;
  final String description;
  final String? photo;
  final DateTime createdAt;

  EmployeeReport({
    required this.id,
    required this.type,
    required this.description,
    this.photo,
    required this.createdAt,
  });

  factory EmployeeReport.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try { return DateTime.parse(value); } catch (_) { return DateTime.now(); }
      }
      if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      return DateTime.now();
    }

    return EmployeeReport(
      id: json['id'] ?? json['_id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      photo: json['photo'],
      createdAt: parseDate(json['createdAt']),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'issue': return 'Issue';
      case 'inventory': return 'Inventory';
      case 'feedback': return 'Feedback';
      default: return type;
    }
  }

  String get formattedDate {
    final d = createdAt.add(const Duration(hours: 1));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
