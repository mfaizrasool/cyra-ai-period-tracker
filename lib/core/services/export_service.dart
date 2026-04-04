import 'package:cyra_ai_period_tracker/data/db/app_database.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> shareHealthExport() async {
    final periods = await _db.getAllPeriodLogs();
    final daily = await _db.getAllDailyLogs();

    final buf = StringBuffer();
    buf.writeln('Cyra — health data export');
    buf.writeln();
    buf.writeln('--- Period logs ---');

    for (final p in periods) {
      buf.writeln('${p.date.toIso8601String().split('T').first}, flow=${p.flowLevel}');
    }

    buf.writeln();
    buf.writeln('--- Daily logs ---');

    for (final d in daily) {
      buf.writeln(
        '${d.date.toIso8601String().split('T').first} | mood=${d.mood} | symptoms=${d.symptoms} | notes=${d.notes}',
      );
    }

    final text = buf.toString();
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Cyra health export'),
    );
  }
}
