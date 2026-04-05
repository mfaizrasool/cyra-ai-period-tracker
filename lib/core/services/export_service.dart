import 'dart:io';
import 'dart:ui' show Rect;

import 'package:cyra_ai_period_tracker/data/db/app_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  final AppDatabase _db = AppDatabase.instance;

  /// Shares a `.txt` export (works more reliably than raw text on iOS, especially iPad).
  /// Pass [sharePositionOrigin] from the tap target (or a screen-centered [Rect]) so the
  /// share popover can anchor — required for iPad / Mac catalyst.
  Future<void> shareHealthExport({Rect? sharePositionOrigin}) async {
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
      final pain = d.painLevel != null ? 'pain=${d.painLevel}' : 'pain=-';
      buf.writeln(
        '${d.date.toIso8601String().split('T').first} | mood=${d.mood} | symptoms=${d.symptoms} | $pain | notes=${d.notes}',
      );
    }

    final text = buf.toString();
    if (text.trim().isEmpty) {
      throw StateError('Nothing to export.');
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/cyra_health_export_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(path);
    await file.writeAsString(text, flush: true);

    final params = ShareParams(
      files: [XFile(path, mimeType: 'text/plain')],
      subject: 'Cyra health export',
      sharePositionOrigin: sharePositionOrigin,
    );

    await SharePlus.instance.share(params);
  }
}
