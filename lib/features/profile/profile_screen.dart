import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/services/family_link_service.dart';
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

  final FamilyLinkService _familyLink = FamilyLinkService();

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapGuardianFamilyCode());
  }

  Future<void> _bootstrapGuardianFamilyCode() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    final snap = await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
    if (!snap.exists) return;
    if (snap.data()?['familyRole'] == 'dependent') return;
    try {
      await _familyLink.ensureFamilyCodeForGuardian(u.uid);
    } catch (_) {}
  }

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
                _familySystemSection(context),

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

  Widget _familySystemSection(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final user = authSnap.data;
        if (user == null) {
          return buildCard(
            title: "family_system".tr(),
            children: [
              Text(
                "history_sign_in".tr(),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          );
        }
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, docSnap) {
            if (docSnap.connectionState == ConnectionState.waiting && !docSnap.hasData) {
              return buildCard(
                title: "family_system".tr(),
                children: const [
                  Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )),
                ],
              );
            }
            final d = docSnap.data?.data();
            if (d == null) {
              return buildCard(
                title: "family_system".tr(),
                children: [
                  Text("family_profile_loading".tr(), style: const TextStyle(color: Colors.grey)),
                ],
              );
            }
            final role = d['familyRole'] as String? ?? 'guardian';
            final isDependent = role == 'dependent';
            final guardianUid = d['guardianUid'] as String?;

            final children = <Widget>[];

            if (isDependent) {
              children.add(
                Text(
                  'family_linked_as_dependent'.tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              );
              if (guardianUid != null) {
                children.add(
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('users').doc(guardianUid).snapshots(),
                    builder: (context, gSnap) {
                      final g = gSnap.data?.data();
                      final gName = g?['displayName'] ?? g?['name'] ?? '—';
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '${'family_guardian_label'.tr()}: $gName',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      );
                    },
                  ),
                );
              }
            } else {
              children.add(_familyCodeShareRow(context, d));
              children.add(const SizedBox(height: 12));
              children.add(_linkedMembersList(user.uid));
              children.add(const SizedBox(height: 12));
              children.add(_guardianInviteChildHint());
            }

            return buildCard(
              title: "family_system".tr(),
              children: children,
            );
          },
        );
      },
    );
  }

  Widget _familyCodeShareRow(BuildContext context, Map<String, dynamic> userData) {
    final code = (userData['familyCode'] as String?)?.trim() ?? '';
    if (code.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'family_code_generating'.tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      );
    }
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
                  await Clipboard.setData(ClipboardData(text: code));
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
              Expanded(
                child: Text(
                  code,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "family_share_code_hint".tr(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _linkedMembersList(String guardianUid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _familyLink.familyLinksForGuardian(guardianUid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SizedBox.shrink();
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text(
            'family_no_members_yet'.tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'family_linked_members'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...docs.map((doc) {
              final m = doc.data();
              final name = (m['dependentName'] as String?)?.trim();
              final email = (m['dependentEmail'] as String?)?.trim();
              final label = name != null && name.isNotEmpty
                  ? name
                  : (email != null && email.isNotEmpty ? email : doc.id);
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
                          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (email != null && email.isNotEmpty && label != email)
                            Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            'family_role_dependent'.tr(),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _guardianInviteChildHint() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'family_guardian_invite_hint'.tr(),
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
          ),
        ),
      ],
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