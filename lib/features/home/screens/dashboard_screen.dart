import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const DashboardScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9FA), // Soft blue/teal background
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Row WITH BACK BUTTON
                _buildTopHeader(context),

                // 2. Branding Hero Section
                _buildBrandingHero(),

                // 3. Health Dashboard Title
                _buildTitleSection(),

                const SizedBox(height: 10),

                // 4. General Status (الحالة العامة)
                _buildGeneralStatusSection(),

                const SizedBox(height: 25),

                // 5. Alerts Section (التنبيهات)
                _buildAlertsSection(),

                const SizedBox(height: 25),

                // 6. Chart Section (الرسم البياني)
                _buildChartSection(),

                const SizedBox(height: 25),

                // 7. Latest Analysis (آخر التحاليل)
                _buildLatestAnalysisSection(),

                const SizedBox(height: 25),

                // 8. Advice Section (النصيحة)
                _buildAdviceSection(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "labby",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1FB6A6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.science_outlined, color: Colors.white, size: 24),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF1F2937), size: 24),
            onPressed: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1FB6A6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              "labby",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          children: const [
            Text(
              "لوحة المتابعة الصحية",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "مرحباً بك، أحمد محمد",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                "الحالة العامة",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.edit_note, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBE6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFE58F), width: 1),
            ),
            child: Column(
              children: const [
                Text(
                  "تحتاج انتباه بسيط",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD48806),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "معظم تحاليلك طبيعية مع ملاحظة بسيطة",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8C8C8C),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                "التنبيهات",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          _buildAlertCard(
            title: "فيتامين D منخفض",
            subtitle: "ننصح بزيارة الطبيب لتحديد الجرعة المناسبة",
            icon: Icons.report_problem_outlined,
            color: const Color(0xFFFAAD14),
            bgColor: const Color(0xFFFFF7E6),
            borderColor: const Color(0xFFFFD591),
          ),
          const SizedBox(height: 12),
          _buildAlertCard(
            title: "موعد تحليل دوري",
            subtitle: "حان موعد فحص السكر التراكمي الشهري",
            icon: Icons.info_outline,
            color: const Color(0xFF1890FF),
            bgColor: const Color(0xFFE6F7FF),
            borderColor: const Color(0xFF91D5FF),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF595959), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                "الرسم البياني",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.auto_graph, color: Colors.redAccent),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildFilterButton("سنة", false),
                    const SizedBox(width: 8),
                    _buildFilterButton("شهر", false),
                    const SizedBox(width: 8),
                    _buildFilterButton("أسبوع", true),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      "مستوى السكر - آخر 7 أيام",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(_sugarLevelData()),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem("القيمة الفعلية", const Color(0xFF1FB6A6), true),
                    const SizedBox(width: 20),
                    _buildLegendItem("الهدف", Colors.orange, false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1FB6A6) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDot) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        isDot
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle))
            : Container(
                width: 20, height: 2, decoration: BoxDecoration(color: color)),
      ],
    );
  }

  LineChartData _sugarLevelData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 30,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
            dashArray: [5, 5]),
        getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
            dashArray: [5, 5]),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              const days = [
                "الجمعة",
                "الأربعاء",
                "الثلاثاء",
                "الاثنين",
                "الأحد",
                "السبت"
              ];
              int index = value.toInt();
              if (index >= 0 && index < days.length) {
                return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(days[index],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)));
              }
              return const Text("");
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 30,
            getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 5,
      minY: 0,
      maxY: 120,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 95),
            FlSpot(1, 105),
            FlSpot(2, 90),
            FlSpot(3, 110),
            FlSpot(4, 95),
            FlSpot(5, 100),
          ],
          isCurved: true,
          color: const Color(0xFF1FB6A6),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF1FB6A6).withOpacity(0.1),
          ),
        ),
        LineChartBarData(
          spots: const [
            FlSpot(0, 80),
            FlSpot(5, 80),
          ],
          isCurved: false,
          color: Colors.orange,
          barWidth: 1,
          dashArray: [5, 5],
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }

  Widget _buildLatestAnalysisSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back_ios,
                        color: Color(0xFF1FB6A6), size: 14),
                    SizedBox(width: 4),
                    Text("عرض الكل",
                        style: TextStyle(
                            color: Color(0xFF1FB6A6),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Row(
                children: const [
                  Text(
                    "آخر التحاليل",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.edit_note, color: Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisItem(
              "تحليل دم شامل",
              "2026-04-01",
              "طبيعي",
              const Color(0xFF52C41A),
              const Color(0xFFF6FFED),
              Icons.water_drop_outlined),
          _buildAnalysisItem(
              "تحليل سكر تراكمي",
              "2026-03-28",
              "ممتاز",
              const Color(0xFF1890FF),
              const Color(0xFFE6F7FF),
              Icons.show_chart),
          _buildAnalysisItem("فيتامين D", "2026-03-25", "منخفض",
              const Color(0xFFF5222D), const Color(0xFFFFF1F0), Icons.error_outline),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String date, String status,
      Color statusColor, Color statusBg, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: statusBg, borderRadius: BorderRadius.circular(12)),
            child: Text(status,
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 4),
                  const Icon(Icons.calendar_today,
                      color: Colors.grey, size: 12),
                ],
              ),
            ],
          ),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: statusBg, shape: BoxShape.circle),
            child: Icon(icon, color: statusColor, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                "النصيحة",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.lightbulb_outline, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD591), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "نصيحة اليوم",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD48806)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Color(0xFFD48806), shape: BoxShape.circle),
                      child:
                          const Icon(Icons.bolt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "حافظ على شرب 8 أكواب من الماء يومياً لتحسين صحتك العامة وتعزيز وظائف الجسم. الماء ضروري لصحة الكلى وتحسين التركيز!",
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFFD48806), height: 1.6),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
