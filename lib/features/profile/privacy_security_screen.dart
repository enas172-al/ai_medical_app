import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/mfa/phone_mfa_flow.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/privacy_settings_firestore_service.dart';

/// Firestore [Timestamp], [GeoPoint], [DocumentReference], etc. are not JSON-encodable as-is.
dynamic _jsonEncodableFromFirestore(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toUtc().toIso8601String();
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is GeoPoint) {
    return {'latitude': value.latitude, 'longitude': value.longitude};
  }
  if (value is DocumentReference) {
    return value.path;
  }
  if (value is Map) {
    return value.map(
      (k, v) => MapEntry(k.toString(), _jsonEncodableFromFirestore(v)),
    );
  }
  if (value is Iterable) {
    return value.map(_jsonEncodableFromFirestore).toList();
  }
  if (value is String || value is num || value is bool) {
    return value;
  }
  return value.toString();
}

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // Authentication toggles
  bool biometricAuth = false;
  bool twoFactorAuth = false;
  bool autoLock = true;

  // Privacy toggles
  bool dataEncryption = true;
  bool familyShare = true;
  bool analyticsData = false;
  bool _twoFactorBusy = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = SettingsService();
    final b = await s.getBiometricAuth();
    final tfa = await s.getTwoFactorAuth();
    final al = await s.getAutoLock();
    final de = await s.getDataEncryption();
    final fs = await s.getFamilyShare();
    final ad = await s.getAnalyticsData();
    if (mounted) {
      setState(() {
        biometricAuth = b;
        twoFactorAuth = tfa;
        autoLock = al;
        dataEncryption = de;
        familyShare = fs;
        analyticsData = ad;
      });
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final remote = await PrivacySettingsFirestoreService().fetch(uid);
      if (!mounted) return;
      if (remote != null) {
        setState(() {
          biometricAuth = remote.biometricAuth;
          twoFactorAuth = remote.twoFactorAuth;
          autoLock = remote.autoLock;
          dataEncryption = remote.dataEncryption;
          familyShare = remote.familyShare;
          analyticsData = remote.analyticsData;
        });
        await s.setBiometricAuth(biometricAuth);
        await s.setTwoFactorAuth(twoFactorAuth);
        await s.setAutoLock(autoLock);
        await s.setDataEncryption(dataEncryption);
        await s.setFamilyShare(familyShare);
        await s.setAnalyticsData(analyticsData);
      } else {
        await PrivacySettingsFirestoreService().syncAll(
          uid,
          biometricAuth: biometricAuth,
          twoFactorAuth: twoFactorAuth,
          autoLock: autoLock,
          dataEncryption: dataEncryption,
          familyShare: familyShare,
          analyticsData: analyticsData,
        );
      }
    } catch (_) {
      // Offline / rules: keep local prefs only.
    }

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      try {
        final factors = await authUser.multiFactor.getEnrolledFactors();
        final enrolled = factors.isNotEmpty;
        if (!mounted) return;
        if (enrolled != twoFactorAuth) {
          setState(() => twoFactorAuth = enrolled);
          await SettingsService().setTwoFactorAuth(enrolled);
          await PrivacySettingsFirestoreService().syncAll(
            authUser.uid,
            biometricAuth: biometricAuth,
            twoFactorAuth: enrolled,
            autoLock: autoLock,
            dataEncryption: dataEncryption,
            familyShare: familyShare,
            analyticsData: analyticsData,
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _onTwoFactorToggle(bool want) async {
    setState(() => _twoFactorBusy = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (want) {
        final factors = await user.multiFactor.getEnrolledFactors();
        if (factors.isNotEmpty) {
          if (!mounted) return;
          setState(() => twoFactorAuth = true);
          await SettingsService().setTwoFactorAuth(true);
          await _savePrivacyToCloud();
          return;
        }
        if (!mounted) return;
        final ok = await PhoneMfaFlow.enrollPhone(context, user);
        if (!mounted) return;
        if (ok) {
          setState(() => twoFactorAuth = true);
          await SettingsService().setTwoFactorAuth(true);
          await _savePrivacyToCloud();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('mfa_enroll_success'.tr())),
            );
          }
        }
      } else {
        final factors = await user.multiFactor.getEnrolledFactors();
        if (factors.isEmpty) {
          if (!mounted) return;
          setState(() => twoFactorAuth = false);
          await SettingsService().setTwoFactorAuth(false);
          await _savePrivacyToCloud();
          return;
        }
        if (!mounted) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('mfa_disable_confirm_title'.tr()),
            content: Text('mfa_disable_confirm_body'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('mfa_disable_confirm_yes'.tr()),
              ),
            ],
          ),
        );
        if (confirm != true) return;
        for (final f in factors) {
          await user.multiFactor.unenroll(multiFactorInfo: f);
        }
        if (!mounted) return;
        setState(() => twoFactorAuth = false);
        await SettingsService().setTwoFactorAuth(false);
        await _savePrivacyToCloud();
      }
    } finally {
      if (mounted) setState(() => _twoFactorBusy = false);
    }
  }

  Future<void> _savePrivacyToCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await PrivacySettingsFirestoreService().syncAll(
        uid,
        biometricAuth: biometricAuth,
        twoFactorAuth: twoFactorAuth,
        autoLock: autoLock,
        dataEncryption: dataEncryption,
        familyShare: familyShare,
        analyticsData: analyticsData,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('settings_sync_failed'.tr(namedArgs: {'err': '$e'}))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "privacy_and_security".tr(),
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
              // 🛡️ Top Secured Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1FB6A6), Color(0xFF17A2A2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1FB6A6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.security_outlined, color: Colors.white, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      "account_protected".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "data_security_guarantee".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔒 Authentication & Security Section
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
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, color: Color(0xFF1FB6A6)),
                        const SizedBox(width: 8),
                        Text(
                          "auth_and_security".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildIconToggleRow(
                      title: "biometric_auth".tr(),
                      subtitle: "biometric_desc".tr(),
                      icon: Icons.fingerprint,
                      iconColor: const Color(0xFF1FB6A6),
                      value: biometricAuth,
                      onChanged: (val) async {
                        setState(() => biometricAuth = val);
                        await SettingsService().setBiometricAuth(val);
                        await _savePrivacyToCloud();
                      },
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildIconToggleRow(
                      title: "two_factor_auth".tr(),
                      subtitle: "two_factor_desc".tr(),
                      icon: Icons.phone_iphone_outlined,
                      iconColor: Colors.purple.shade300,
                      value: twoFactorAuth,
                      onChanged: _twoFactorBusy
                          ? null
                          : (val) {
                              _onTwoFactorToggle(val);
                            },
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildIconToggleRow(
                      title: "auto_lock".tr(),
                      subtitle: "auto_lock_desc".tr(),
                      icon: Icons.lock_outline,
                      iconColor: Colors.blueAccent,
                      value: autoLock,
                      onChanged: (val) async {
                        setState(() => autoLock = val);
                        await SettingsService().setAutoLock(val);
                        await _savePrivacyToCloud();
                      },
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildArrowActionRow(
                      title: "change_password".tr(),
                      subtitle: "change_password_desc".tr(),
                      icon: Icons.key_outlined,
                      iconColor: Colors.orange.shade400,
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 👁️ Privacy Settings Section
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
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF1FB6A6)),
                        const SizedBox(width: 8),
                        Text(
                          "privacy_settings".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextToggleRow(
                      title: "data_encryption_toggle".tr(),
                      subtitle: "data_encryption_desc".tr(),
                      value: dataEncryption,
                      onChanged: (val) async {
                        setState(() => dataEncryption = val);
                        await SettingsService().setDataEncryption(val);
                        await _savePrivacyToCloud();
                      },
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildTextToggleRow(
                      title: "family_share".tr(),
                      subtitle: "family_share_desc".tr(),
                      value: familyShare,
                      onChanged: (val) async {
                        setState(() => familyShare = val);
                        await SettingsService().setFamilyShare(val);
                        await _savePrivacyToCloud();
                      },
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildTextToggleRow(
                      title: "analytics_data".tr(),
                      subtitle: "analytics_data_desc".tr(),
                      value: analyticsData,
                      onChanged: (val) async {
                        setState(() => analyticsData = val);
                        await SettingsService().setAnalyticsData(val);
                        await _savePrivacyToCloud();
                      },
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildTextArrowRow(
                      title: "download_my_data".tr(),
                      subtitle: "download_my_data_desc".tr(),
                      onTap: () => _showDownloadDataDialog(context),
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildTextArrowRow(
                      title: "delete_my_account".tr(),
                      subtitle: "delete_my_account_desc".tr(),
                      isDestructive: true,
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 💡 Security Tips Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFBE4A0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock, color: Color(0xFFD4A017), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "security_tips".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B4D00),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTipRow("tip_strong_password".tr()),
                    const SizedBox(height: 10),
                    _buildTipRow("tip_dont_share".tr()),
                    const SizedBox(height: 10),
                    _buildTipRow("tip_enable_2fa".tr()),
                    const SizedBox(height: 10),
                    _buildTipRow("tip_review_activity".tr()),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: Color(0xFFD4A017)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B4D00),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconToggleRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
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
              const SizedBox(height: 2),
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

  Widget _buildArrowActionRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
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
                const SizedBox(height: 2),
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
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  Widget _buildTextToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
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
              const SizedBox(height: 2),
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

  Widget _buildTextArrowRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDestructive ? Colors.red : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
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
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isLoading = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.all(20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: const EdgeInsets.all(20),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "change_password".tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (!isLoading)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMsg != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        errorMsg!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  _buildPasswordField("current_password".tr(), oldPassCtrl, showVisibilityIcon: true),
                  const SizedBox(height: 16),
                  _buildPasswordField("new_password".tr(), newPassCtrl),
                  const SizedBox(height: 16),
                  _buildPasswordField("confirm_password".tr(), confirmPassCtrl),
                  const SizedBox(height: 8),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final oldP = oldPassCtrl.text;
                            final newP = newPassCtrl.text;
                            final confirmP = confirmPassCtrl.text;
                            
                            if (oldP.isEmpty || newP.isEmpty || confirmP.isEmpty) {
                              setStateDialog(() => errorMsg = "الرجاء تعبئة جميع الحقول");
                              return;
                            }
                            if (newP != confirmP) {
                              setStateDialog(() => errorMsg = "كلمتا المرور غير متطابقتين");
                              return;
                            }
                            if (newP.length < 6) {
                              setStateDialog(() => errorMsg = "كلمة المرور الجديدة ضعيفة (6 أحرف على الأقل)");
                              return;
                            }

                            setStateDialog(() {
                              isLoading = true;
                              errorMsg = null;
                            });

                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null || user.email == null) {
                                throw Exception("لا يوجد حساب مسجل حالياً.");
                              }

                              // Re-authenticate
                              final cred = EmailAuthProvider.credential(
                                email: user.email!,
                                password: oldP,
                              );
                              await user.reauthenticateWithCredential(cred);

                              // Update password
                              await user.updatePassword(newP);

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('password_changed_success'.tr())),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              setStateDialog(() {
                                isLoading = false;
                                errorMsg = e.message ?? "حدث خطأ في المصادقة";
                              });
                            } catch (e) {
                              setStateDialog(() {
                                isLoading = false;
                                errorMsg = e.toString();
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1FB6A6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("save_password".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, {bool showVisibilityIcon = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: showVisibilityIcon ? const Icon(Icons.visibility_outlined, color: Colors.grey) : null,
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordCtrl = TextEditingController();
    bool isLoading = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.all(20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: const EdgeInsets.all(20),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        "delete_my_account".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                      ),
                    ],
                  ),
                  if (!isLoading)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorMsg != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              "important_warning".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildBulletPoint("delete_warning_1".tr(), Colors.red),
                          _buildBulletPoint("delete_warning_2".tr(), Colors.red),
                          _buildBulletPoint("delete_warning_3".tr(), Colors.red),
                          _buildBulletPoint("delete_warning_4".tr(), Colors.red),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        text: "delete_confirmation_text".tr(),
                        children: [
                          TextSpan(text: "delete_confirm_phrase".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "أدخل كلمة المرور للتأكيد",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final pass = passwordCtrl.text;
                                if (pass.isEmpty) {
                                  setStateDialog(() => errorMsg = "يرجى إدخال كلمة المرور لتأكيد الحذف");
                                  return;
                                }

                                setStateDialog(() {
                                  isLoading = true;
                                  errorMsg = null;
                                });

                                try {
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user == null || user.email == null) {
                                    throw Exception("لا يوجد حساب مسجل حالياً.");
                                  }

                                  // Re-authenticate
                                  final cred = EmailAuthProvider.credential(
                                    email: user.email!,
                                    password: pass,
                                  );
                                  await user.reauthenticateWithCredential(cred);

                                  // Delete Firestore User Document
                                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                                  
                                  // Clear Settings
                                  await SettingsService().clearAllSettings();

                                  // Delete Firebase Auth User
                                  await user.delete();

                                  if (context.mounted) {
                                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                                  }
                                } on FirebaseAuthException catch (e) {
                                  setStateDialog(() {
                                    isLoading = false;
                                    errorMsg = e.message ?? "حدث خطأ في المصادقة";
                                  });
                                } catch (e) {
                                  setStateDialog(() {
                                    isLoading = false;
                                    errorMsg = e.toString();
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text("delete_account_permanently".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("cancel".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, color: color, size: 6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.9), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog(BuildContext context) {
    bool isExporting = false;
    String? exportStatus;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.all(20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: const EdgeInsets.all(20),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.download_rounded, color: Color(0xFF1FB6A6)),
                      const SizedBox(width: 8),
                      Text(
                        "download_my_data".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  if (!isExporting)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (exportStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(exportStatus!, style: const TextStyle(color: Color(0xFF1FB6A6), fontWeight: FontWeight.bold)),
                    ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FB6A6).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1FB6A6).withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      "download_data_process_desc".tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isExporting
                            ? null
                            : () async {
                                setStateDialog(() {
                                  isExporting = true;
                                  exportStatus = "جاري تجميع البيانات...";
                                });
                                try {
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user == null) throw Exception("No user found");

                                  final db = FirebaseFirestore.instance;
                                  
                                  // Fetch user doc
                                  final userDoc = await db.collection('users').doc(user.uid).get();
                                  
                                  // Fetch meds
                                  setStateDialog(() => exportStatus = "جاري تجميع الأدوية...");
                                  // Root collections (same paths as [DatabaseService]); NOT users/{uid}/...
                                  final medsQuery = await db
                                      .collection('medications')
                                      .where('userId', isEqualTo: user.uid)
                                      .get();

                                  // Fetch analyses
                                  setStateDialog(() => exportStatus = "جاري تجميع التحاليل...");
                                  final analysesQuery = await db
                                      .collection('analyses')
                                      .where('userId', isEqualTo: user.uid)
                                      .get();

                                  final data = {
                                    "user_profile": _jsonEncodableFromFirestore(
                                          userDoc.data() ?? <String, dynamic>{},
                                        ) ??
                                        <String, dynamic>{},
                                    "medications": medsQuery.docs
                                        .map((e) => _jsonEncodableFromFirestore(e.data()))
                                        .toList(),
                                    "analyses": analysesQuery.docs
                                        .map((e) => _jsonEncodableFromFirestore(e.data()))
                                        .toList(),
                                    "export_date": DateTime.now().toIso8601String(),
                                  };

                                  final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
                                  
                                  setStateDialog(() => exportStatus = "جاري تجهيز الملف...");
                                  final tempDir = await getTemporaryDirectory();
                                  final file = File('${tempDir.path}/health_data_export_${user.uid.substring(0, 5)}.json');
                                  await file.writeAsString(jsonStr);

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    await Share.shareXFiles([XFile(file.path)], text: 'My Labby Health Data Export');
                                  }
                                } catch (e) {
                                  setStateDialog(() {
                                    isExporting = false;
                                    exportStatus = "فشل التصدير: $e";
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1FB6A6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isExporting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text("extract_copy".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isExporting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("cancel".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }
}
