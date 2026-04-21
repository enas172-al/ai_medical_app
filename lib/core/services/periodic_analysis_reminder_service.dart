import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';

/// Schedules periodic lab analysis reminders as local notifications only.
class PeriodicAnalysisReminderService {
  PeriodicAnalysisReminderService._();
  static final PeriodicAnalysisReminderService instance = PeriodicAnalysisReminderService._();

  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      await NotificationService.instance.requestPermissionsIfNeeded();
      await NotificationService.instance.schedulePeriodicLabReminders(
        monthlyTitle: 'periodic_monthly_title'.tr(),
        monthlyBody: 'periodic_monthly_body'.tr(),
        semiAnnualTitle: 'periodic_semiannual_title'.tr(),
        semiAnnualBody: 'periodic_semiannual_body'.tr(),
      );
    } catch (e) {
      debugPrint('PeriodicAnalysisReminderService: $e');
    }
  }
}
