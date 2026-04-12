import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 1;
  String _currentUser = 'example_name'.tr();
  bool isPersonal = true;
  void switchUser(String userName, bool personal) {
    setState(() {
      _currentUser = userName;
      isPersonal = personal;
    });
  }

  final List<Map<String, dynamic>> _allTests = [
    {
      'title': 'fasting_sugar'.tr(),
      'sub': 'Glucose',
      'value': '98',
      'unit': 'mg/dL',
      'status': 'normal_status'.tr(),
      'date': 'example_dob'.tr(),
    },
    {
      'title': 'hemoglobin'.tr(),
      'sub': 'Hemoglobin',
      'value': '14.2',
      'unit': 'g/dL',
      'status': 'normal_status'.tr(),
      'date': 'example_dob'.tr(),
    },
    {
      'title': 'cholesterol'.tr(),
      'sub': 'Cholesterol',
      'value': '185',
      'unit': 'mg/dL',
      'status': 'high_status'.tr(),
      'date': 'example_dob'.tr(),
    },
    {
      'title': 'vitamin_d'.tr(),
      'sub': 'Vitamin D',
      'value': '32',
      'unit': 'ng/mL',
      'status': 'low_status'.tr(),
      'date': 'example_dob'.tr(),
    },
  ];

  List<Map<String, dynamic>> get _recentTests {
    return _allTests.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _selectedTab == 0 ? _recentTests : _allTests;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),

      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                  const SizedBox(height: 10),

                  /// Switch User Header (Hidden if it's the personal account)
                    if (!isPersonal)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.elderly, color: Colors.white),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "you_are_tracking".tr(),
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  Text(
                                    _currentUser,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                switchUser("محمد أحمد", true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withAlpha(50),
                                foregroundColor: Colors.white,
                              ),
                              child: Text("cancel".tr()),
                            )
                          ],
                        ),
                      ),

              // 🧾 Title
              Text(
                isPersonal ? "history_title".tr() : "user_history_title".tr(args: [_currentUser]),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,

                ),
              ),

              const SizedBox(height: 6),

              Text(
                "history_subtitle".tr(),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 25),

              // 🔘 Tabs (RTL Swap)
              Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? const Color(0xFF1FB6A6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedTab == 1 ? Colors.transparent : Colors.grey.shade200,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "all_tests_tab".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? const Color(0xFF1FB6A6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedTab == 0 ? Colors.transparent : Colors.grey.shade200,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "latest_tab".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
              ),

                    const SizedBox(height: 25),

                    // 📊 List
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final test = list[index];
                          return _buildHistoryCard(context, test);
                        },
                      ),
                    ),
                  ],
              ),
          ),
      ),
    );
  }


  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> test) {
    return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/chart',
            arguments: test,
          );
        },
        child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                
                // 🔘 سهم (Right in RTL)
                const Icon(Icons.arrow_back, color: Colors.grey, size: 20),

                const SizedBox(width: 12),

                // 🔢 دائرة النتائج (Middle)
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FB6A6).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "12",
                          style: TextStyle(
                            color: Color(0xFF1FB6A6),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "results_count".tr(args: ["12"]),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      test['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      test['sub'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "last_update".tr() + ": ${test['date']}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ],
            ),
        ),
    );
  }
}
