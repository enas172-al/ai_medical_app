import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/services/family_link_service.dart';

/// Family accounts from Firestore: signed-in user + linked dependents (guardian)
/// or signed-in user + guardian row (dependent).
class SwitchAccountScreen extends StatelessWidget {
  /// Which profile is highlighted when opening; defaults to [FirebaseAuth.currentUser] uid.
  final String? initialSelectedUid;

  /// When false (e.g. medication list), dependents only see their own row — not guardian (no read access to parent's meds).
  final bool showGuardianRowForDependent;

  const SwitchAccountScreen({
    super.key,
    this.initialSelectedUid,
    this.showGuardianRowForDependent = true,
  });

  Stream<DocumentSnapshot<Map<String, dynamic>>> _guardianLinkDocStream(String dependentUid) {
    return FirebaseFirestore.instance
        .collection(FamilyLinkService.linksCollection)
        .doc(dependentUid)
        .snapshots();
  }

  static String _displayNameFromDoc(Map<String, dynamic>? d, User u) {
    final dn = (d?['displayName'] as String?)?.trim();
    final n = (d?['name'] as String?)?.trim();
    final authN = u.displayName?.trim();
    final email = (u.email ?? (d?['email'] as String?) ?? '').trim();
    if (dn != null && dn.isNotEmpty) return dn;
    if (n != null && n.isNotEmpty) return n;
    if (authN != null && authN.isNotEmpty) return authN;
    if (email.isNotEmpty) return email.split('@').first;
    return '—';
  }

  /// Dependents from `users.where('guardianUid' == guardian)` (names/emails stay fresh).
  static List<Map<String, dynamic>> _accountsForGuardianFromUserDocs(
    User u,
    Map<String, dynamic>? data,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> dependentUserDocs,
  ) {
    final self = _displayNameFromDoc(data, u);
    final list = <Map<String, dynamic>>[
      {
        'uid': u.uid,
        'displayName': self,
        'accountType': 'personal',
        'tag': 'my_account_tag'.tr(),
        'subtitle': (u.email ?? (data?['email'] as String?) ?? '').trim(),
      },
    ];
    for (final doc in dependentUserDocs) {
      final depUid = doc.id;
      if (depUid == u.uid) continue;
      final m = doc.data();
      final dn = (m['displayName'] as String?)?.trim();
      final n = (m['name'] as String?)?.trim();
      final em = (m['email'] as String?)?.trim() ?? '';
      final label = (dn != null && dn.isNotEmpty)
          ? dn
          : (n != null && n.isNotEmpty)
              ? n
              : (em.isNotEmpty ? em.split('@').first : depUid);
      list.add({
        'uid': depUid,
        'displayName': label,
        'accountType': 'dependent',
        'tag': 'family_member_tag'.tr(),
        'subtitle': em,
      });
    }
    return list;
  }

  static List<Map<String, dynamic>> _accountsForDependent(
    User u,
    Map<String, dynamic>? data,
    Map<String, dynamic>? guardianData,
    String guardianUid,
  ) {
    final self = _displayNameFromDoc(data, u);
    final gDisplay = () {
      final dn = (guardianData?['displayName'] as String?)?.trim();
      final n = (guardianData?['name'] as String?)?.trim();
      final em = (guardianData?['email'] as String?)?.trim() ?? '';
      if (dn != null && dn.isNotEmpty) return dn;
      if (n != null && n.isNotEmpty) return n;
      if (em.isNotEmpty) return em.split('@').first;
      return 'family_guardian_label'.tr();
    }();

    return [
      {
        'uid': u.uid,
        'displayName': self,
        'accountType': 'personal',
        'tag': 'my_account_tag'.tr(),
        'subtitle': (u.email ?? (data?['email'] as String?) ?? '').trim(),
      },
      {
        'uid': guardianUid,
        'displayName': gDisplay,
        'accountType': 'guardian',
        'tag': 'family_role_guardian'.tr(),
        'subtitle': (guardianData?['email'] as String?)?.trim() ?? '',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final u = authSnap.data;
        if (u == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F9F9),
            body: Center(child: Text('history_sign_in'.tr())),
          );
        }

        final highlightUid = initialSelectedUid ?? u.uid;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(u.uid).snapshots(),
          builder: (context, userSnap) {
            final data = userSnap.data?.data();
            final role = data?['familyRole'] as String?;
            final rawGuardianUid = (data?['guardianUid'] as String?)?.trim() ?? '';
            final isDependent = role == 'dependent' || rawGuardianUid.isNotEmpty;

            if (isDependent) {
              final gUid = rawGuardianUid.isNotEmpty ? rawGuardianUid : (data?['guardianUid'] as String?);
              final selfOnly = [
                {
                  'uid': u.uid,
                  'displayName': _displayNameFromDoc(data, u),
                  'accountType': 'personal',
                  'tag': 'my_account_tag'.tr(),
                  'subtitle': (u.email ?? (data?['email'] as String?) ?? '').trim(),
                },
              ];
              if (!showGuardianRowForDependent) {
                return _buildScaffold(context, u, data, selfOnly, highlightUid);
              }

              // Prefer guardianUid on the user doc; if missing (older data / partial sync),
              // fall back to family_links/{dependentUid}.guardianUid.
              if (gUid != null && gUid.isNotEmpty) {
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').doc(gUid).snapshots(),
                  builder: (context, gSnap) {
                    final accounts = _accountsForDependent(u, data, gSnap.data?.data(), gUid);
                    return _buildScaffold(context, u, data, accounts, highlightUid);
                  },
                );
              }

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _guardianLinkDocStream(u.uid),
                builder: (context, linkSnap) {
                  final link = linkSnap.data?.data();
                  final resolved = (link?['guardianUid'] as String?)?.trim() ?? '';
                  if (resolved.isEmpty) {
                    return _buildScaffold(
                      context,
                      u,
                      data,
                      selfOnly,
                      highlightUid,
                      bannerText: 'family_guardian_missing'.tr(),
                      isBannerError: false,
                    );
                  }
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('users').doc(resolved).snapshots(),
                    builder: (context, gSnap) {
                      final accounts = _accountsForDependent(u, data, gSnap.data?.data(), resolved);
                      return _buildScaffold(context, u, data, accounts, highlightUid);
                    },
                  );
                },
              );
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FamilyLinkService().dependentUserProfilesForGuardian(u.uid),
              builder: (context, depsSnap) {
                if (depsSnap.hasError) {
                  final accounts =
                      _accountsForGuardianFromUserDocs(u, data, []);
                  return _buildScaffold(
                    context,
                    u,
                    data,
                    accounts,
                    highlightUid,
                    bannerText: 'family_accounts_load_error'.tr(),
                    isBannerError: true,
                  );
                }
                if (depsSnap.connectionState == ConnectionState.waiting &&
                    !depsSnap.hasData) {
                  return _buildLoadingShell(context);
                }
                final depDocs = depsSnap.data?.docs ?? [];
                final accounts = _accountsForGuardianFromUserDocs(u, data, depDocs);
                final onlySelf = depDocs.isEmpty;
                return _buildScaffold(
                  context,
                  u,
                  data,
                  accounts,
                  highlightUid,
                  listFooterHint:
                      onlySelf ? 'family_no_linked_members'.tr() : null,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingShell(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F9F9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1FB6A6)),
              const SizedBox(height: 16),
              Text('select_account'.tr(),
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    User u,
    Map<String, dynamic>? data,
    List<Map<String, dynamic>> accounts,
    String highlightUid, {
    String? bannerText,
    bool isBannerError = false,
    String? listFooterHint,
  }) {
    final loggedName = _displayNameFromDoc(data, u);
    final roleLabel = data?['familyRole'] == 'dependent'
        ? 'family_role_dependent'.tr()
        : 'family_role_guardian'.tr();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F9F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF08DAB6), Color(0xFF20A89B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1FB6A6).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              "select_account".tr(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            Text("choose_who_to_track".tr(), style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "you_are_logged_in_as".tr(),
                                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  loggedName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  roleLabel,
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1FB6A6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.face, color: Colors.white, size: 30),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (bannerText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isBannerError
                              ? Colors.red.shade50
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isBannerError
                                ? Colors.red.shade200
                                : Colors.amber.shade200,
                          ),
                        ),
                        child: Text(
                          bannerText,
                          style: TextStyle(
                            fontSize: 13,
                            color: isBannerError
                                ? Colors.red.shade900
                                : Colors.amber.shade900,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      "available_accounts".tr(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 16),
                    ...accounts.map((acc) {
                      final uid = acc['uid'] as String;
                      final isSelected = uid == highlightUid;
                      final accountType = acc['accountType'] as String;
                      final isPersonal = accountType == 'personal';
                      final isGuardianRow = accountType == 'guardian';
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop<Map<String, dynamic>>(context, {
                            'uid': uid,
                            'displayName': acc['displayName'],
                            'accountType': accountType,
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF1FB6A6) : Colors.grey.shade200,
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF1FB6A6).withValues(alpha: 0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1FB6A6),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  isPersonal
                                      ? Icons.face
                                      : isGuardianRow
                                          ? Icons.supervisor_account
                                          : Icons.family_restroom,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc['displayName'] as String,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                    ),
                                    if ((acc['subtitle'] as String? ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        acc['subtitle'] as String? ?? '',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isPersonal ? const Color(0xFF1FB6A6) : const Color(0xFFF3E8FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isPersonal
                                                ? Icons.person_outline
                                                : isGuardianRow
                                                    ? Icons.shield_outlined
                                                    : Icons.family_restroom,
                                            size: 14,
                                            color: isPersonal ? Colors.white : const Color(0xFF7C3AED),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            acc['tag'] as String,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isPersonal ? Colors.white : const Color(0xFF7C3AED),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF1FB6A6),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (listFooterHint != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        listFooterHint,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F2937),
                          elevation: 0,
                          side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("return_to_profile".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
