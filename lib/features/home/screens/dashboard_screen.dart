import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "لوحة المتابعة الصحية",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00CED1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Color(0xFF00CED1), size: 20),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                       Text(
                        "لابي | labby",
                        style: TextStyle(color: Color(0xFF1FB6A6), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "مرحباً بك، أحمد محمد",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00CED1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.science, color: Colors.white, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Top 3 Cards
              Row(
                children: [
                  _buildMetricCard("الأهداف", "75%", const Color(0xFFFF4500), const Color(0xFFFF8C00)),
                  const SizedBox(width: 12),
                  _buildMetricCard("الإنجازات", "12", const Color(0xFF8E54E9), const Color(0xFF4776E6)),
                  const SizedBox(width: 12),
                  _buildMetricCard("التحاليل", "28", const Color(0xFF00CED1), const Color(0xFF20B2AA)),
                ],
              ),
              const SizedBox(height: 30),

              // Vital Indicators Section
              const Text(
                "المؤشرات الحيوية",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildVitalCard("نبضات القلب", "72", "نبضة/د", "طبيعي", Icons.favorite, Colors.red),
                  _buildVitalCard("الأكسجين", "98", "%", "ممتاز", Icons.bolt, Colors.blue),
                  _buildVitalCard("السعرات الحرارية", "2400", "سعرة", "متوازن", Icons.local_fire_department, Colors.orange),
                  _buildVitalCard("المياه", "2.1", "لتر", "جيد", Icons.water_drop, Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 30),

              // Today's Goals Section
              const Text(
                "أهداف اليوم",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildGoalItem("شرب الماء", "6 من 8 أكواب", 0.75, Colors.blue),
              _buildGoalItem("النشاط البدني", "45 من 60 دقيقة", 0.75, Colors.green),
              _buildGoalItem("النوم", "7 من 8 ساعات", 0.88, Colors.indigo),
              _buildGoalItem("الوجبات الصحية", "3 من 3 وجبات", 1.0, Colors.teal),
              const SizedBox(height: 30),

              // Sugar level Chart
              _buildChartHeader("مستوى السكر", ["سنة", "شهر", "أسبوع"]),
              const SizedBox(height: 16),
              _buildSugarChart(),
              const SizedBox(height: 30),

              // Blood Pressure Chart
              _buildChartHeader("ضغط الدم", ["سنة", "شهر", "أسبوع"]),
              const SizedBox(height: 16),
              _buildPressureChart(),
              const SizedBox(height: 30),
              
               // Analytical Distribution
              const Text(
                "توزيع التحاليل",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDistributionChart(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color startColor, Color endColor) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [startColor, endColor]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          const Spacer(),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(status, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String title, String subtitle, double progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
               Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.check_circle_outline, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Text("${(progress * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildChartHeader(String title, List<String> periods) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
             const Icon(Icons.trending_up, color: Color(0xFF1FB6A6), size: 18),
             const SizedBox(width: 8),
             Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: periods.map((p) => Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: p == "أسبوع" ? const Color(0xFF1FB6A6) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(p, style: TextStyle(color: p == "أسبوع" ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSugarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  const days = ["السبت", "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة"];
                   if (v >= 0 && v < days.length) return Text(days[v.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10));
                   return const Text("");
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [const FlSpot(0, 95), const FlSpot(1, 102), const FlSpot(2, 98), const FlSpot(3, 110), const FlSpot(4, 95), const FlSpot(5, 105), const FlSpot(6, 115)],
              isCurved: true,
              color: const Color(0xFF1FB6A6),
              barWidth: 3,
              dotData: FlDotData(show: true, getDotPainter: (spot, p, bar, index) => FlDotCirclePainter(radius: 4, color: const Color(0xFF1FB6A6), strokeWidth: 2, strokeColor: Colors.white)),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF1FB6A6).withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPressureChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
           gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(show: true, rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [const FlSpot(0, 120), const FlSpot(1, 118), const FlSpot(2, 122), const FlSpot(3, 125), const FlSpot(4, 120), const FlSpot(5, 122), const FlSpot(6, 125)],
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: [const FlSpot(0, 80), const FlSpot(1, 78), const FlSpot(2, 82), const FlSpot(3, 85), const FlSpot(4, 80), const FlSpot(5, 82), const FlSpot(6, 85)],
              isCurved: true,
              color: Colors.orangeAccent,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(color: const Color(0xFF1FB6A6), value: 40, title: "40%", radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  PieChartSectionData(color: Colors.blueAccent, value: 30, title: "30%", radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  PieChartSectionData(color: Colors.orangeAccent, value: 20, title: "20%", radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  PieChartSectionData(color: Colors.redAccent, value: 10, title: "10%", radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem("تحليل دم", const Color(0xFF1FB6A6)),
              _buildLegendItem("سكر", Colors.blueAccent),
              _buildLegendItem("كوليسترول", Colors.orangeAccent),
              _buildLegendItem("أخرى", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
