import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'notification_settings_screen.dart';
import 'privacy_security_screen.dart';
import 'language_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

                // 👤 User Card
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
                    children: const [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30, color: Color(0xFF1FB6A6)),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "أحمد محمد",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ahmed@example.com",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 📄 Info Card
                buildCard(
                  title: "personal_info".tr(),
                  children: [
                    infoRow("full_name".tr(), "أحمد محمد علي", Icons.person, Colors.teal),
                    infoRow("email".tr(), "ahmed@example.com", Icons.email, Colors.blue),
                    infoRow("date_of_birth".tr(), "15 يناير 1990", Icons.calendar_today, Colors.purple),
                    infoRow("gender".tr(), "male".tr(), Icons.wc, Colors.pink),
                  ],
                ),

                const SizedBox(height: 20),

                // 👨‍👩‍👧 Family System
                buildCard(
                  title: "family_system".tr(),
                  children: [
                    familyCode(),
                    const SizedBox(height: 12),
                    familyMember("سارة أحمد", "wife".tr()),
                    familyMember("محمد أحمد", "son".tr()),
                    const SizedBox(height: 12),
                    addFamilyButton(),
                  ],
                ),

                const SizedBox(height: 20),

                // ⚙️ Settings
                buildCard(
                  title: "settings".tr(),
                  children: [
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

                // 🚪 Logout
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

  // 📦 Card
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

  // 🎯 Info Row
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

  // 👨‍👩‍👧 Family Code
  Widget familyCode() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.copy),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "FAM-2026-ABC123",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 👤 Family Member
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

  // ➕ Add Family
  Widget addFamilyButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text("link_family_account".tr()),
      ),
    );
  }

  // ⚙️ Settings Row
  Widget settingRow(String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}