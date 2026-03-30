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
          title: Text(
            test['title'],
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

              const Text(
              "الرسم البياني",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // 📊 Chart Card
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: SizedBox(
                    height: 250,
                    child: LineChart(
                        LineChartData(

                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: 10,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.shade200,
                                  strokeWidth: 1,
                                );
                              },
                            ),

                            borderData: FlBorderData(show: false),

                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text("يناير");
                                      case 1:
                                        return const Text("فبراير");
                                      case 2:
                                        return const Text("مارس");
                                      default:
                                        return const Text("");
                                    }
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                ),
                              ),
                            ),

                            lineBarsData: [
                            LineChartBarData(
                            isCurved: true,
                            curveSmoothness: 0.4,
                            color: const Color(0xFF1FB6A6),
                            barWidth: 4,

                            spots: const [
                              FlSpot(0, 91),
                              FlSpot(1, 87),
                              FlSpot(2, 95),
                              FlSpot(3, 112),
                              FlSpot(4, 98),
                              FlSpot(5, 96),
                            ],

                            dotData: FlDotData(
                              show: true,getDotPainter: (spot, percent, bar, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF1FB6A6),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                            ),

                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF1FB6A6).withOpacity(0.1),
                              ),
                            ),
                            ],
                        ),
                    ),
                ),
            ),

                const SizedBox(height: 20),

                // 📊 Value Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FB6A6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${test['value']} ${test['unit']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1FB6A6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        test['title'],
                        style: const TextStyle(fontSize: 14),
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