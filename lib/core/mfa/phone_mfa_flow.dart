import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Converts common **Libya** local formats to E.164 (`+218…`) and tidies other `+` inputs.
/// Firebase Phone Auth requires international form (leading `+` and country code).
String? _normalizePhoneInputToE164(String raw) {
  var t = raw.trim().replaceAll(RegExp(r'[\s\-\u200f\u200e]'), '');
  if (t.isEmpty) return null;

  if (t.startsWith('++')) {
    t = '+${t.substring(2).replaceAll('+', '')}';
  }

  if (t.startsWith('+')) {
    final digits = t.substring(1).replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return _fixLibyaTrunkZeroAfter218('+$digits');
  }

  if (t.startsWith('00')) {
    final digits = t.substring(2).replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return _fixLibyaTrunkZeroAfter218('+$digits');
  }

  final digits = t.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;

  if (digits.startsWith('218')) {
    return _fixLibyaTrunkZeroAfter218('+$digits');
  }

  // Libya local mobile: 09xxxxxxxx (leading 0 is national trunk)
  if (RegExp(r'^09\d{8}$').hasMatch(digits)) {
    return '+218${digits.substring(1)}';
  }

  // Libya without leading 0: 9xxxxxxxx (9 digits)
  if (RegExp(r'^9\d{8}$').hasMatch(digits)) {
    return '+218$digits';
  }

  return null;
}

/// If user wrote `+218091…` (extra 0 after country code), normalize to `+21891…`.
String _fixLibyaTrunkZeroAfter218(String e164) {
  if (e164.startsWith('+2180')) {
    return '+218${e164.substring(5)}';
  }
  return e164;
}

/// Phone (SMS) second factor using Firebase Auth multi-factor APIs.
class PhoneMfaFlow {
  PhoneMfaFlow._();

  static Future<String?> _promptPhone(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _MfaPhoneInputDialog(),
    );
  }

  static Future<String?> _promptSmsCode(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _MfaSmsCodeDialog(),
    );
  }

  /// Enrolls SMS as a second factor for the signed-in [user].
  static Future<bool> enrollPhone(BuildContext context, User user) async {
    final raw = await _promptPhone(context);
    if (raw == null || raw.isEmpty) return false;
    final phone = _normalizePhoneInputToE164(raw);
    if (phone == null || !phone.startsWith('+')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('mfa_invalid_phone'.tr())),
        );
      }
      return false;
    }

    final session = await user.multiFactor.getSession();
    final completer = Completer<bool>();
    var finished = false;

    Future<void> completeEnroll(PhoneAuthCredential credential) async {
      await user.multiFactor.enroll(
        PhoneMultiFactorGenerator.getAssertion(credential),
        displayName: 'mfa_factor_phone'.tr(),
      );
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        multiFactorSession: session,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (finished) return;
          finished = true;
          try {
            await completeEnroll(credential);
            if (!completer.isCompleted) completer.complete(true);
          } catch (e) {
            finished = false;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('mfa_enroll_failed'.tr(namedArgs: {'err': '$e'}))),
              );
            }
            if (!completer.isCompleted) completer.complete(false);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? e.code)),
            );
          }
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) async {
          if (finished) return;
          if (!context.mounted) {
            if (!completer.isCompleted) completer.complete(false);
            return;
          }
          final code = await _promptSmsCode(context);
          if (code == null || code.isEmpty) {
            if (!completer.isCompleted) completer.complete(false);
            return;
          }
          if (finished) return;
          finished = true;
          try {
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: code,
            );
            await completeEnroll(credential);
            if (!completer.isCompleted) completer.complete(true);
          } catch (e) {
            finished = false;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('mfa_enroll_failed'.tr(namedArgs: {'err': '$e'}))),
              );
            }
            if (!completer.isCompleted) completer.complete(false);
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('mfa_enroll_failed'.tr(namedArgs: {'err': '$e'}))),
        );
      }
      return false;
    }

    return completer.future;
  }

  /// Completes sign-in after [FirebaseAuthMultiFactorException] (email/Google first step).
  static Future<UserCredential?> resolveSignIn(
    BuildContext context,
    FirebaseAuthMultiFactorException e,
  ) async {
    final resolver = e.resolver;
    PhoneMultiFactorInfo? phoneHint;
    for (final h in resolver.hints) {
      if (h is PhoneMultiFactorInfo) {
        phoneHint = h;
        break;
      }
    }
    if (phoneHint == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('mfa_totp_not_supported'.tr())),
        );
      }
      return null;
    }

    final completer = Completer<UserCredential?>();
    var finished = false;

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: resolver.session,
        multiFactorInfo: phoneHint,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (finished) return;
          finished = true;
          try {
            final uc = await resolver.resolveSignIn(
              PhoneMultiFactorGenerator.getAssertion(credential),
            );
            if (!completer.isCompleted) completer.complete(uc);
          } catch (err) {
            finished = false;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('mfa_sign_in_failed'.tr(namedArgs: {'err': '$err'}))),
              );
            }
            if (!completer.isCompleted) completer.complete(null);
          }
        },
        verificationFailed: (FirebaseAuthException ex) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ex.message ?? ex.code)),
            );
          }
          if (!completer.isCompleted) completer.complete(null);
        },
        codeSent: (String verificationId, int? resendToken) async {
          if (finished) return;
          if (!context.mounted) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }
          final code = await _promptSmsCode(context);
          if (code == null || code.isEmpty) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }
          if (finished) return;
          finished = true;
          try {
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: code,
            );
            final uc = await resolver.resolveSignIn(
              PhoneMultiFactorGenerator.getAssertion(credential),
            );
            if (!completer.isCompleted) completer.complete(uc);
          } catch (err) {
            finished = false;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('mfa_sign_in_failed'.tr(namedArgs: {'err': '$err'}))),
              );
            }
            if (!completer.isCompleted) completer.complete(null);
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('mfa_sign_in_failed'.tr(namedArgs: {'err': '$err'}))),
        );
      }
      return null;
    }

    return completer.future;
  }
}

class _MfaPhoneInputDialog extends StatefulWidget {
  const _MfaPhoneInputDialog();

  @override
  State<_MfaPhoneInputDialog> createState() => _MfaPhoneInputDialogState();
}

class _MfaPhoneInputDialogState extends State<_MfaPhoneInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('mfa_enter_phone_title'.tr()),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'mfa_phone_hint'.tr(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text('mfa_continue'.tr()),
        ),
      ],
    );
  }
}

class _MfaSmsCodeDialog extends StatefulWidget {
  const _MfaSmsCodeDialog();

  @override
  State<_MfaSmsCodeDialog> createState() => _MfaSmsCodeDialogState();
}

class _MfaSmsCodeDialogState extends State<_MfaSmsCodeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('mfa_enter_sms_title'.tr()),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'mfa_sms_hint'.tr(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text('mfa_verify'.tr()),
        ),
      ],
    );
  }
}
