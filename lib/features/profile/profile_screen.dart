import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'notification_settings_screen.dart';
import 'privacy_security_screen.dart';
import 'language_screen.dart';
import 'help_support_screen.dart';
import '../home/screens/dashboard_screen.dart';
import 'switch_account_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _currentUser = 'محمد أحمد';
  String _loggedInUser = 'محمد أحمد';
  String _loggedInUserRole = 'companion_role'.tr();

  final List<Map<String, dynamic>> _accounts = [
    {
      'name': 'example_family_member_2'.tr(),
      'type': 'dependent',
      'age': 'years_old'.tr(args: ['65']),
      'tag': 'family_member_tag'.tr(),
    },
    {
      'name': 'example_name'.tr(),
      'type': 'personal',
      'age': 'years_old'.tr(args: ['35']),
      'tag': 'my_account_tag'.tr(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // User Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1FB6A6), Color(0xFF17A2A2)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30, color: Color(0xFF1FB6A6)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentUser,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "ahmed@example.com",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                //  Info Card
                buildCard(
                  title: "personal_info".tr(),
                  children: [
                    infoRow("full_name".tr(), "example_name".tr(), Icons.person, Colors.teal),
                    infoRow("email".tr(), "ahmed@example.com", Icons.email, Colors.blue),
                    infoRow("date_of_birth".tr(), "example_dob".tr(), Icons.calendar_today, Colors.purple),
                    infoRow("gender".tr(), "male".tr(), Icons.wc, Colors.pink),
                  ],
                ),

                const SizedBox(height: 20),

                //  Family System
                buildCard(
                  title: "family_system".tr(),
                  children: [
                    familyCode(context),
                    const SizedBox(height: 12),
                    familyMember("example_family_member_1".tr(), "wife".tr()),
                    familyMember("example_family_member_2".tr(), "son".tr()),
                    const SizedBox(height: 12),
                    addFamilyButton(context),
                  ],
                ),

                const SizedBox(height: 20),


                buildCard(
                  title: "settings".tr(),
                  children: [
                    settingRow(
                      "switch_account".tr(),
                      leadingIcon: Icons.sync,
                      iconColor: const Color(0xFF1FB6A6),
                      onTap: _showUserSelection,
                    ),
                    settingRow(
                      "health_tracking_dashboard".tr(),
                      leadingIcon: Icons.bar_chart,
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      },
                    ),
                    settingRow("notifications".tr(), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsScreen(),
                        ),
                      );
                    }),
                    settingRow("privacy_and_security".tr(), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySecurityScreen(),
                        ),
                      );
                    }),
                    settingRow("language".tr(), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageScreen(),
                        ),
                      );
                    }),
                    settingRow("help_and_support".tr(), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 20),


                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Center(
                    child: Text(
                      "logout".tr(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card
  Widget buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  // Info Row
  Widget infoRow(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  Family Code
  Widget familyCode(BuildContext context) {
    const String code = "FAM-2026-ABC123";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(const ClipboardData(text: code));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('link_account_success'.tr())),
                    );
                  }
                },
                child: const Icon(Icons.copy, color: Color(0xFF1FB6A6)),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Share.share("share_profile_msg".tr(args: [code]));
                },
                child: const Icon(Icons.share, color: Color(0xFF1FB6A6)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  code,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            " شارك هذا الكود مع أفراد عائلتك لربط حساباتهم ".tr(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // Family Member
  Widget familyMember(String name, String role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(role, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  //  Add Family
  Widget addFamilyButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLinkAccountDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), // Acting as dashed
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF111827), size: 20),
            const SizedBox(width: 8),
            Text(
              "link_family_account".tr(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkAccountDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Link Account",
      pageBuilder: (context, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Directionality(
              textDirection: Directionality.of(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("link_family_account_dialog_title".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.grey, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("enter_family_code".tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const TextField(
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        hintText: "FAM-2026-XXXXXX",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1FB6A6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('link_account_success'.tr())));
                      },
                      child: Text("link_account_btn".tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: ScaleTransition(scale: anim1, child: child));
      },
    );
  }

  //  Settings Row
  Widget settingRow(String title, {VoidCallback? onTap, IconData? leadingIcon, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(leadingIcon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showUserSelection() async {
    final selected = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SwitchAccountScreen(
          currentUser: _currentUser,
          loggedInUser: _loggedInUser,
          loggedInUserRole: _loggedInUserRole,
          accounts: _accounts,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    if (selected != null && selected is String) {
      setState(() {
        _currentUser = selected;
      });
    }
  }
}