import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 1; // 0 = الأحدث, 1 = جميع التحاليل

  // قائمة التحاليل
  final List<Map<String, dynamic>> _allTests = [
    {
      'title': 'سكر الدم',
      'sub': 'Glucose',
      'value': '98',
      'unit': 'mg/dL',
      'status': 'طبيعي',
      'date': '20 مارس 2026',
      'time': '08:30 صباحاً',
    },
    {
      'title': 'الهيموجلوبين',
      'sub': 'Hemoglobin',
      'value': '14.2',
      'unit': 'g/dL',
      'status': 'طبيعي',
      'date': '20 مارس 2026',
      'time': '08:30 صباحاً',
    },
    {
      'title': 'الكوليسترول',
      'sub': 'Cholesterol',
      'value': '185',
      'unit': 'mg/dL',
      'status': 'مرتفع',
      'date': '18 مارس 2026',
      'time': '10:15 صباحاً',
    },
    {
      'title': 'فيتامين د',
      'sub': 'Vitamin D',
      'value': '32',
      'unit': 'ng/mL',
      'status': 'ناقص',
      'date': '15 مارس 2026',
      'time': '09:00 صباحاً',
    },
    {
      'title': 'ضغط الدم',
      'sub': 'Blood Pressure',
      'value': '120/80',
      'unit': 'mmHg',
      'status': 'طبيعي',
      'date': '10 مارس 2026',
      'time': '07:45 صباحاً',
    },
  ];

  // التحاليل الأحدث (آخر 3)
  List<Map<String, dynamic>> get _recentTests {
    return _allTests.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🧾 Title
            const Text(
              "سجل التحاليل",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "جميع تحاليلك السابقة في مكان واحد",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // 🔘 Tabs (الأحدث / جميع التحاليل)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? const Color(0xFF1FB6A6)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "الأحدث",
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? const Color(0xFF1FB6A6)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "جميع التحاليل",
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 📊 List
            Expanded(
              child: (_selectedTab == 0 ? _recentTests : _allTests).isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "لا توجد تحاليل",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "سيظهر هنا تاريخ تحاليلك",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _selectedTab == 0 ? _recentTests.length : _allTests.length,
                itemBuilder: (context, index) {
                  final test = _selectedTab == 0
                      ? _recentTests[index]
                      : _allTests[index];
                  return _buildHistoryCard(test);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧾 Card محسن
  Widget _buildHistoryCard(Map<String, dynamic> test) {
    // تحديد لون الحالة
    Color statusColor;
    switch (test['status']) {
      case 'طبيعي':
        statusColor = const Color(0xFF10B981);
        break;
      case 'مرتفع':
        statusColor = const Color(0xFFEF4444);
        break;
      case 'ناقص':
        statusColor = const Color(0xFFF59E0B);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة السهم (للتفاصيل)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 12),

          // القيمة
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF1FB6A6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    test['value'],
                    style: const TextStyle(
                      color: Color(0xFF1FB6A6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    test['unit'],
                    style: const TextStyle(
                      color: Color(0xFF1FB6A6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),

          // معلومات التحليل (على اليمين)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  test['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  test['sub'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        test['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.circle,
                      size: 4,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      test['date'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}