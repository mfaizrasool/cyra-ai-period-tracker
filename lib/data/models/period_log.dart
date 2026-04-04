class PeriodLog {
  final int? id;
  final DateTime date;
  final int flowLevel; // 0: None, 1: Spotting, 2: Light, 3: Medium, 4: Heavy
  final bool isPredicted;
  
  PeriodLog({
    this.id,
    required this.date,
    required this.flowLevel,
    this.isPredicted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'flowLevel': flowLevel,
      'isPredicted': isPredicted ? 1 : 0,
    };
  }

  factory PeriodLog.fromMap(Map<String, dynamic> map) {
    final parsed = DateTime.parse(map['date'] as String);
    return PeriodLog(
      id: map['id'] as int?,
      date: DateTime(parsed.year, parsed.month, parsed.day),
      flowLevel: map['flowLevel'] as int,
      isPredicted: map['isPredicted'] == 1,
    );
  }
}
