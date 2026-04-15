import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

import '../../core/services/medication_reminder_sync_service.dart';
import '../../core/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = true;
  bool _syncingMeds = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB), // Adjusted for the light cyan background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        centerTitle: true, // Though RTL might shift it, we set true or just title
        title: Text(
          "notifications".tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Methods Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "notification_methods".tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildToggleRow(
                      title: "push_notifications".tr(),
                      subtitle: "push_notifications_desc".tr(),
                      icon: Icons.notifications_none,
                      iconColor: const Color(0xFF1FB6A6),
                      value: pushEnabled,
                      onChanged: (val) => setState(() => pushEnabled = val),
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildToggleRow(
                      title: "email_notifications".tr(),
                      subtitle: "email_notifications_desc".tr(),
                      icon: Icons.email_outlined,
                      iconColor: Colors.blueAccent,
                      value: emailEnabled,
                      onChanged: (val) => setState(() => emailEnabled = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          pushEnabled = false;
                          emailEnabled = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.notifications_off_outlined, color: Colors.grey.shade600),
                      label: Text(
                        "disable_all".tr(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          pushEnabled = true;
                          emailEnabled = true;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF1FB6A6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_none, color: Color(0xFF1FB6A6)),
                      label: Text(
                        "enable_all".tr(),
                        style: const TextStyle(
                          color: Color(0xFF1FB6A6),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Medication reminders sync
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تذكيرات الأدوية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'إذا كنت بدّلت هاتف أو حذفت التطبيق، اضغط هنا لإعادة تفعيل تذكيرات كل أدويتك على هذا الجهاز.',
                      style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _syncingMeds
                            ? null
                            : () async {
                                setState(() => _syncingMeds = true);
                                try {
                                  final enabled = await NotificationService.instance.areNotificationsEnabled();
                                  if (enabled == false && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('الإشعارات مقفولة للتطبيق. فعّلها من إعدادات الجهاز ثم جرّب مرة ثانية.'),
                                      ),
                                    );
                                  }
                                  await MedicationReminderSyncService.instance.resyncNow();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم إعادة تفعيل تذكيرات الأدوية.')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('صار خطأ: $e')),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _syncingMeds = false);
                                }
                              },
                        icon: _syncingMeds
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(_syncingMeds ? 'جاري...' : 'إعادة تفعيل تذكيرات الأدوية'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1FB6A6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD6E2F9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8BB8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "important_info".tr(),
                            style: const TextStyle(
                              color: Color(0xFF1A4582),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "notification_control_desc".tr(),
                            style: const TextStyle(
                              color: Color(0xFF335C94),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: Colors.black87,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }
}
