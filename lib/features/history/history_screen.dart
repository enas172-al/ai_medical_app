import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 1;

  final List<Map<String, dynamic>> _allTests = [
    {
      'title': 'سكر الدم',
      'sub': 'Glucose',
      'value': '98',
      'unit': 'mg/dL',
      'status': 'طبيعي',
      'date': '20 مارس 2026',
    },
    {
      'title': 'الهيموجلوبين',
      'sub': 'Hemoglobin',
      'value': '14.2',
      'unit': 'g/dL',
      'status': 'طبيعي',
      'date': '20 مارس 2026',
    },
    {
      'title': 'الكوليسترول',
      'sub': 'Cholesterol',
      'value': '185',
      'unit': 'mg/dL',
      'status': 'مرتفع',
      'date': '18 مارس 2026',
    },
    {
      'title': 'فيتامين د',
      'sub': 'Vitamin D',
      'value': '32',
      'unit': 'ng/mL',
      'status': 'ناقص',
      'date': '15 مارس 2026',
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
                  children: [

                  const SizedBox(height: 10),

              // 🧾 Title
              const Text(
                "سجل التحاليل",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "جميع تحاليلك السابقة في مكان واحد",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // 🔘 Tabs
              Row(
                  children: [
              Expanded(
              child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
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
                  : Colors.grey,
            ),
          ),
        ),
      ),
    ),
    ),
    const SizedBox(width: 10),
    Expanded(
    child: GestureDetector(
    onTap: () => setState(() => _selectedTab = 1),
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
        : Colors.grey,
    ),
    ),
    ),
    ),),
    ),
                  ],
              ),

                    const SizedBox(height: 20),

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

  // 🔥 الكارد + الضغط
  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> test) {
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
        statusColor = Colors.grey;
    }

    return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/chart',
            arguments: test, // 🔥 أهم سطر
          );
        },
        child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [

              // 🔘 سهم
              Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const SizedBox(width: 10),

            // 🔢 القيمة
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF1FB6A6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
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
                      ),
                    ),
                    Text(
                      test['unit'],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 📄 النص
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  Text(
                  test['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  test['sub'],
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 6),

                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    test['status'],
                    style: TextStyle(color: statusColor,
                      fontSize: 11,
                    ),
                ),
                ),
                      const SizedBox(width: 8),
                      Text(
                        test['date'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                ),
                  ],
                ),
            ),
              ],
            ),
        ),
    );
  }
}