class DailyLog {
  final int? id;
  final DateTime date;
  final String symptoms; // comma separated
  final String mood;
  final String notes;

  DailyLog({
    this.id,
    required this.date,
    this.symptoms = '',
    this.mood = '',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'mood': mood,
      'notes': notes,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    final parsed = DateTime.parse(map['date'] as String);
    return DailyLog(
      id: map['id'] as int?,
      date: DateTime(parsed.year, parsed.month, parsed.day),
      symptoms: map['symptoms'] as String? ?? '',
      mood: map['mood'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }
}
