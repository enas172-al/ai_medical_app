import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/family_link_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await AuthService().signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FamilyLinkException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.messageKey.tr())),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login_fill_fields'.tr())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FamilyLinkException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.messageKey.tr())),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1FB6A6),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: 40),

              // Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                   'assets/images/logo.png',
                  width: 45,
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "app_title".tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "your_health_companion".tr(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 30),

              // Card
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // عنوان
                      Center(
                        child: Text(
                          "login_title".tr(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 25),

                      // البريد الإلكتروني
                      Text("email".tr()),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "example@email.com",
                          prefixIcon: Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // كلمة المرور
                      Text("password".tr()),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "********",
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 5),

                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () async {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('الرجاء إدخال البريد الإلكتروني أولاً')),
                              );
                              return;
                            }
                            try {
                              await AuthService().resetPassword(email);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم إرسال رابط إعادة التعيين لبريدك الإلكتروني')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                String msg = "Error: ${e.toString()}";
                                if (e.toString().contains("account_not_found")) {
                                  msg = "البريد الإلكتروني غير مسجل لدينا، يرجى التأكد منه أو إنشاء حساب جديد.";
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(msg)),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "هل نسيت كلمة المرور؟",
                            style: TextStyle(
                              color: Color(0xFF1FB6A6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // زر الدخول
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1FB6A6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleEmailLogin,
                          child: Text(
                            "login_btn".tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                        Center(
                        child: GestureDetector(
                      
                          child: Text(
                            "أو",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 119, 122, 121),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                        SizedBox(height: 10),
                      // زر تسجيل الدخول مع جوجل
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: Image.asset(
                            'assets/images/google_logo.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.g_mobiledata, size: 30, color: Colors.blue),
                          ),
                          label: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                  "المتابعة باستخدام Google     ",
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // إنشاء حساب
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            "no_account_register".tr(),
                            style: const TextStyle(
                              color: Color(0xFF1FB6A6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
