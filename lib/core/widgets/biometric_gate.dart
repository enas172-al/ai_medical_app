import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/settings_service.dart';

class BiometricGate extends StatefulWidget {
  final Widget child;

  /// Wraps the destination screen to enforce biometric authentication if enabled in settings.
  const BiometricGate({super.key, required this.child});

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isChecking = true;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-lock feature integration
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null) {
        final diff = DateTime.now().difference(_pausedTime!);
        // If app was in background for > 30 seconds, re-authenticate
        if (diff.inSeconds > 30) {
          setState(() {
            _isAuthenticated = false;
            _isChecking = true;
          });
          _checkBiometrics();
        }
      }
    }
  }

  Future<void> _checkBiometrics() async {
    final settings = SettingsService();
    final authEnabled = await settings.getBiometricAuth();
    final autoLockEnabled = await settings.getAutoLock();

    // If biometric is completely disabled in settings
    if (!authEnabled) {
      if (mounted) setState(() { _isChecking = false; _isAuthenticated = true; });
      return;
    }

    final localAuth = LocalAuthentication();
    final canCheck = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();

    // If device doesn't support biometrics, allow entry gracefully
    if (!canCheck || !isSupported) {
      if (mounted) setState(() { _isChecking = false; _isAuthenticated = true; });
      return;
    }

    try {
      final didAuthenticate = await localAuth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك لفتح التطبيق',
        options: const AuthenticationOptions(
          biometricOnly: false, // Allows PIN/Password fallback 
          stickyAuth: true,
        ),
      );

      if (mounted) {
        setState(() {
          _isChecking = false;
          _isAuthenticated = didAuthenticate;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _isAuthenticated = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1FB6A6)),
        ),
      );
    }

    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1FB6A6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, size: 60, color: Color(0xFF1FB6A6)),
            ),
            const SizedBox(height: 24),
            const Text(
              "التطبيق مقفل",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "يرجى التحقق من هويتك للوصول إلى بياناتك",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isChecking = true);
                _checkBiometrics();
              },
              icon: const Icon(Icons.fingerprint, color: Colors.white),
              label: const Text("فتح التطبيق", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1FB6A6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
