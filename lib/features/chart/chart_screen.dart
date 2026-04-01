import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map) {
      return Scaffold(
        body: Center(
          child: Text("لا توجد بيانات"),
        ),
      );
    }

    final test = args;

    return Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "جميع النتائج",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                const Text(
                  "الرسم البياني",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // 📊 Chart Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 20,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade100,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0: return const Text("1 فب", style: TextStyle(fontSize: 10, color: Colors.grey));
                                  case 1: return const Text("15 فب", style: TextStyle(fontSize: 10, color: Colors.grey));
                                  case 2: return const Text("1 مار", style: TextStyle(fontSize: 10, color: Colors.grey));
                                  case 3: return const Text("15 مار", style: TextStyle(fontSize: 10, color: Colors.grey));
                                  case 4: return const Text("20 مار", style: TextStyle(fontSize: 10, color: Colors.grey));
                                  default: return const Text("");
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: const Color(0xFF1FB6A6),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF1FB6A6),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF1FB6A6).withOpacity(0.1),
                            ),
                            spots: const [
                              FlSpot(0, 95),
                              FlSpot(1, 110),
                              FlSpot(2, 98),
                              FlSpot(3, 95),
                              FlSpot(4, 95),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "نتائج سابقة",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                // 📄 قائمة النتائج (Image 2 Style)
                _buildResultItem("mg/dL 95", "20 مارس", "طبيعي", const Color(0xFF10B981)),
                _buildResultItem("mg/dL 95", "15 مارس", "طبيعي", const Color(0xFF10B981)),
                _buildResultItem("mg/dL 98", "1 مارس", "طبيعي", const Color(0xFF10B981)),
                _buildResultItem("mg/dL 110", "15 فبراير", "مرتفع", const Color(0xFFEF4444)),
                _buildResultItem("mg/dL 95", "1 فبراير", "طبيعي", const Color(0xFF10B981)),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildResultItem(String value, String date, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔘 الحالة (Left Side)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  "- $status",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (status == "مرتفع") ...[
                  const SizedBox(width: 4),
                  Icon(Icons.trending_up, color: color, size: 16),
                ]
              ],
            ),
          ),

          // 🔢 القيمة والتاريخ (Right Side)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}