import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'database_service.dart';
import 'notification_service.dart';

/// Keeps local medication reminders in sync with Firestore for the signed-in user.
///
/// This solves the common case where meds were added earlier (or from another device)
/// and the current device didn't schedule local reminders yet.
class MedicationReminderSyncService {
  MedicationReminderSyncService._();
  static final MedicationReminderSyncService instance = MedicationReminderSyncService._();

  StreamSubscription<User?>? _authSub;
  StreamSubscription? _medsSub;
  final Set<String> _scheduledMedIds = <String>{};

  bool _started = false;

  void start() {
    if (_started || kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) return;
    _started = true;

    // Start immediately for current user, and react to sign-in/out.
    _onUser(FirebaseAuth.instance.currentUser);
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onUser);
  }

  Future<void> resyncNow() async {
    if (kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await NotificationService.instance.requestPermissionsIfNeeded();
    final meds = await DatabaseService().getMedicationsOnce(user.uid, includeInactive: false);
    for (final m in meds) {
      final id = m.id;
      if (id == null || id.isEmpty) continue;
      if (m.times.isEmpty) continue;
      await NotificationService.instance.scheduleMedicationReminders(
        medId: id,
        medicationName: m.name,
        times: m.times,
      );
      _scheduledMedIds.add(id);
    }
  }

  void _onUser(User? user) {
    _medsSub?.cancel();
    _medsSub = null;
    _scheduledMedIds.clear();
    if (user == null) return;

    // Ensure permissions; if disabled, we still keep syncing/cancelling, but scheduling will no-op.
    NotificationService.instance.requestPermissionsIfNeeded();

    _medsSub = DatabaseService().getMedications(user.uid).listen((meds) async {
      final currentIds = meds.map((m) => m.id).whereType<String>().toSet();

      // Cancel reminders for removed/inactive meds.
      final toCancel = _scheduledMedIds.difference(currentIds);
      for (final id in toCancel) {
        await NotificationService.instance.cancelMedicationReminders(id);
        _scheduledMedIds.remove(id);
      }

      // Schedule (or re-schedule) reminders for current meds.
      for (final m in meds) {
        final id = m.id;
        if (id == null || id.isEmpty) continue;
        if (m.times.isEmpty) continue;
        await NotificationService.instance.scheduleMedicationReminders(
          medId: id,
          medicationName: m.name,
          times: m.times,
        );
        _scheduledMedIds.add(id);
      }
    }, onError: (e) {
      debugPrint('MedicationReminderSyncService: $e');
    });
  }
}

