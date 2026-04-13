import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/analysis_model.dart';
import '../../core/services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _GroupedTest {
  _GroupedTest({
    required this.testName,
    required this.displayTitle,
    required this.displaySub,
    required this.count,
    required this.lastDate,
    required this.lastStatus,
  });

  final String testName;
  final String displayTitle;
  final String displaySub;
  final int count;
  final DateTime lastDate;
  final String lastStatus;
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 1;
  String _currentUser = 'example_name'.tr();
  bool isPersonal = true;
  final DatabaseService _db = DatabaseService();

  void switchUser(String userName, bool personal) {
    setState(() {
      _currentUser = userName;
      isPersonal = personal;
    });
  }

  String _titleForTest(String testName) {
    switch (testName) {
      case 'Glucose':
        return 'fasting_sugar'.tr();
      case 'Hemoglobin':
        return 'hemoglobin'.tr();
      case 'Cholesterol':
        return 'cholesterol'.tr();
      case 'Vitamin D':
        return 'vitamin_d'.tr();
      default:
        return testName;
    }
  }

  String _subForTest(String testName) {
    switch (testName) {
      case 'Glucose':
        return 'glucose_sub'.tr();
      case 'Hemoglobin':
        return 'hemoglobin_sub'.tr();
      case 'Cholesterol':
        return 'cholesterol_sub'.tr();
      case 'Vitamin D':
        return 'vitamin_d_sub'.tr();
      default:
        return testName;
    }
  }

  List<_GroupedTest> _groupAnalyses(List<AnalysisModel> all) {
    final map = <String, List<AnalysisModel>>{};
    for (final a in all) {
      map.putIfAbsent(a.testName, () => []).add(a);
    }
    final rows = map.entries.map((e) {
      final sorted = [...e.value]..sort((a, b) => b.date.compareTo(a.date));
      final latest = sorted.first;
      return _GroupedTest(
        testName: e.key,
        displayTitle: _titleForTest(e.key),
        displaySub: _subForTest(e.key),
        count: sorted.length,
        lastDate: latest.date,
        lastStatus: latest.status,
      );
    }).toList();
    rows.sort((a, b) => b.lastDate.compareTo(a.lastDate));
    return rows;
  }

  String _formatDate(DateTime d) {
    return DateFormat.yMMMd(context.locale.toString()).format(d);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Low':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return const Color(0xFF10B981);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Low':
        return 'low_status'.tr();
      case 'High':
        return 'high_status'.tr();
      default:
        return 'normal_status'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? const Color(0xFF1FB6A6) : Colors.white,
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
                              color: _selectedTab == 1 ? Colors.white : Colors.grey,
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
                          color: _selectedTab == 0 ? const Color(0xFF1FB6A6) : Colors.white,
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
                              color: _selectedTab == 0 ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              if (uid == null)
                Expanded(
                  child: Center(child: Text("history_sign_in".tr(), textAlign: TextAlign.center)),
                )
              else
                Expanded(
                  child: StreamBuilder<List<AnalysisModel>>(
                    stream: _db.getAnalyses(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final all = snapshot.data ?? [];
                      if (all.isEmpty) {
                        return Center(child: Text("history_empty".tr(), textAlign: TextAlign.center));
                      }
                      final grouped = _groupAnalyses(all);
                      final list = _selectedTab == 0 ? grouped.take(3).toList() : grouped;
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final row = list[index];
                          return _buildHistoryCard(context, row);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, _GroupedTest row) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/chart',
          arguments: {
            'testName': row.testName,
            'displayTitle': row.displayTitle,
          },
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
            const Icon(Icons.arrow_back, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
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
                    Text(
                      '${row.count}',
                      style: const TextStyle(
                        color: Color(0xFF1FB6A6),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "results_count".tr(args: ['${row.count}']),
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
                  row.displayTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  row.displaySub,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "${"last_update".tr()}: ${_formatDate(row.lastDate)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor(row.lastStatus).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(row.lastStatus),
                        style: TextStyle(
                          fontSize: 11,
                          color: _statusColor(row.lastStatus),
                          fontWeight: FontWeight.w600,
                        ),
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
