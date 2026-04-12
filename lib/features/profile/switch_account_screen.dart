import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SwitchAccountScreen extends StatefulWidget {
  final String currentUser;
  final String loggedInUser;
  final String loggedInUserRole;
  final List<Map<String, dynamic>> accounts;

  const SwitchAccountScreen({
    super.key,
    required this.currentUser,
    required this.loggedInUser,
    required this.loggedInUserRole,
    required this.accounts,
  });

  @override
  State<SwitchAccountScreen> createState() => _SwitchAccountScreenState();
}

class _SwitchAccountScreenState extends State<SwitchAccountScreen> {
  late String _selectedUser;

  @override
  void initState() {
    super.initState();
    _selectedUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F9F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            /// Header Icon
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
                    color: const Color(0xFF1FB6A6).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),

            /// Title
            Text("select_account".tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(height: 4),
            Text("choose_who_to_track".tr(), style: const TextStyle(fontSize: 15, color: Colors.grey)),

            const SizedBox(height: 32),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Logged In Card
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
                                Text("you_are_logged_in_as".tr(), style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                Text(widget.loggedInUser, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                                const SizedBox(height: 4),
                                Text(widget.loggedInUserRole, style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
                    Text("available_accounts".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    const SizedBox(height: 16),

                    /// Accounts List
                    ...widget.accounts.map((acc) {
                      bool isSelected = acc['name'] == _selectedUser;
                      bool isPersonal = acc['type'] == 'personal';
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUser = acc['name'];
                          });
                          Navigator.pop(context, acc['name']);
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
                            boxShadow: isSelected ? [
                              BoxShadow(color: const Color(0xFF1FB6A6).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))
                            ] : [],
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
                                child: Icon(isPersonal ? Icons.face : Icons.elderly, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(acc['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                    const SizedBox(height: 6),
                                    Text(acc['age'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                                          Icon(isPersonal ? Icons.person_outline : Icons.family_restroom,
                                               size: 14,
                                               color: isPersonal ? Colors.white : const Color(0xFF7C3AED)),
                                          const SizedBox(width: 6),
                                          Text(acc['tag'], style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isPersonal ? Colors.white : const Color(0xFF7C3AED)
                                          )),
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

                    const SizedBox(height: 16),

                    /// Return Button
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
