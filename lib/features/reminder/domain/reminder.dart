class Reminder {
  final String id;
  final String title;
  final String subtitle;
  final DateTime scheduledDate;

  Reminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.scheduledDate,
  });

  Reminder copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? scheduledDate,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'scheduledDate': scheduledDate.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      scheduledDate: DateTime.parse(map['scheduledDate'] as String),
    );
  }
}
