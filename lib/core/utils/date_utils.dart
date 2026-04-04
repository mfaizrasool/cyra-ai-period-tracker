/// Calendar-date helpers (local, no time-of-day drift).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String dateKey(DateTime d) {
  final x = dateOnly(d);
  return '${x.year.toString().padLeft(4, '0')}-'
      '${x.month.toString().padLeft(2, '0')}-'
      '${x.day.toString().padLeft(2, '0')}';
}

int calendarDaysBetween(DateTime a, DateTime b) {
  return dateOnly(a).difference(dateOnly(b)).inDays;
}
