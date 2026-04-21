import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Keys
  static const _biometricAuthKey = "settings_biometric_auth";
  static const _twoFactorAuthKey = "settings_two_factor_auth";
  static const _autoLockKey = "settings_auto_lock";
  
  static const _dataEncryptionKey = "settings_data_encryption";
  static const _familyShareKey = "settings_family_share";
  static const _analyticsDataKey = "settings_analytics_data";

  static const _pushEnabledKey = "settings_push_enabled";
  static const _emailEnabledKey = "settings_email_enabled";

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Authentication Toggles ---

  Future<void> setBiometricAuth(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_biometricAuthKey, value);
  }

  Future<bool> getBiometricAuth() async {
    final prefs = await _prefs;
    // Default to false for security features, requires explicit opt-in
    return prefs.getBool(_biometricAuthKey) ?? false;
  }

  Future<void> setTwoFactorAuth(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_twoFactorAuthKey, value);
  }

  Future<bool> getTwoFactorAuth() async {
    final prefs = await _prefs;
    return prefs.getBool(_twoFactorAuthKey) ?? false;
  }

  Future<void> setAutoLock(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_autoLockKey, value);
  }

  Future<bool> getAutoLock() async {
    final prefs = await _prefs;
    return prefs.getBool(_autoLockKey) ?? true;
  }

  // --- Privacy Toggles ---

  Future<void> setDataEncryption(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_dataEncryptionKey, value);
  }

  Future<bool> getDataEncryption() async {
    final prefs = await _prefs;
    return prefs.getBool(_dataEncryptionKey) ?? true;
  }

  Future<void> setFamilyShare(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_familyShareKey, value);
  }

  Future<bool> getFamilyShare() async {
    final prefs = await _prefs;
    return prefs.getBool(_familyShareKey) ?? true;
  }

  Future<void> setAnalyticsData(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_analyticsDataKey, value);
  }

  Future<bool> getAnalyticsData() async {
    final prefs = await _prefs;
    return prefs.getBool(_analyticsDataKey) ?? false;
  }

  // --- Notification Toggles ---

  Future<void> setPushEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_pushEnabledKey, value);
  }

  Future<bool> getPushEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_pushEnabledKey) ?? true;
  }

  Future<void> setEmailEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_emailEnabledKey, value);
  }

  Future<bool> getEmailEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_emailEnabledKey) ?? true;
  }

  /// Wipe settings purely used after account deletion
  Future<void> clearAllSettings() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
