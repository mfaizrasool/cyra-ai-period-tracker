import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:flutter/material.dart';

enum CyclePhaseKind {
  menstrual,
  follicular,
  fertile,
  ovulationDay,
  luteal,
}

class CyclePhaseInfo {
  const CyclePhaseInfo({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final CyclePhaseKind kind;
  final String title;
  final String subtitle;
  final Color accentColor;

  static CyclePhaseInfo resolve({
    required DateTime today,
    required DateTime ovulationDate,
    required List<DateTime> fertileWindow,
    required int? periodDayInBleeding,
  }) {
    if (periodDayInBleeding != null) {
      return const CyclePhaseInfo(
        kind: CyclePhaseKind.menstrual,
        title: 'Menstrual phase',
        subtitle:
            'Rest when you can, stay hydrated, and use heat or gentle movement for cramps if it helps.',
        accentColor: AppColors.periodColor,
      );
    }

    final ov = dateOnly(ovulationDate);
    final td = dateOnly(today);

    if (isSameCalendarDay(td, ov)) {
      return const CyclePhaseInfo(
        kind: CyclePhaseKind.ovulationDay,
        title: 'Ovulation window',
        subtitle:
            'Energy and mood often shift mid-cycle. Listen to your body and adjust intensity as needed.',
        accentColor: AppColors.ovulationColor,
      );
    }

    final inFertile = fertileWindow.any((d) => isSameCalendarDay(d, td));
    if (inFertile) {
      return const CyclePhaseInfo(
        kind: CyclePhaseKind.fertile,
        title: 'Fertile window',
        subtitle:
            'Cervical mucus and basal patterns can shift—this app is for wellness tracking, not contraception.',
        accentColor: AppColors.fertileColor,
      );
    }

    if (td.isBefore(ov)) {
      return const CyclePhaseInfo(
        kind: CyclePhaseKind.follicular,
        title: 'Follicular phase',
        subtitle:
            'Many people feel more energy and focus after their period—good time for goals and movement.',
        accentColor: AppColors.insightColor,
      );
    }

    return const CyclePhaseInfo(
      kind: CyclePhaseKind.luteal,
      title: 'Luteal phase',
      subtitle:
          'PMS-style symptoms are common. Prioritize sleep, nourishment, and lighter workouts if you prefer.',
      accentColor: AppColors.greyColor,
    );
  }
}
