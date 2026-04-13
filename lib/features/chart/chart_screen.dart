import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/analysis_model.dart';
import '../../core/services/database_service.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Future<List<AnalysisModel>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_future != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    String? testName;
    if (args is Map && args['testName'] is String) {
      testName = args['testName'] as String;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && testName != null) {
      _future = DatabaseService().getAnalysesByTestName(uid, testName);
    } else {
      _future = Future.value([]);
    }
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
    final args = ModalRoute.of(context)?.settings.arguments;
    String displayTitle = 'all_results_title'.tr();
    if (args is Map && args['displayTitle'] is String) {
      displayTitle = args['displayTitle'] as String;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          displayTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<AnalysisModel>>(
        future: _future ?? Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(child: Text("no_data_found".tr()));
          }

          final spots = <FlSpot>[];
          for (var i = 0; i < data.length; i++) {
            spots.add(FlSpot(i.toDouble(), data[i].value));
          }

          final dateFmt = DateFormat.MMMd(context.locale.toString());
          double minY = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
          double maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
          final pad = (maxY - minY).abs() < 1e-6 ? 5.0 : (maxY - minY) * 0.15;
          minY = (minY - pad).floorToDouble();
          maxY = (maxY + pad).ceilToDouble();
          if (minY < 0 && data.every((e) => e.value >= 0)) minY = 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "chart_card_title".tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
                          minY: minY,
                          maxY: maxY,
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: (maxY - minY) > 0 ? (maxY - minY) / 4 : 1,
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
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      dateFmt.format(data[i].date),
                                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                                    ),
                                  );
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
                              spots: spots,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "previous_results_title".tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ...data.reversed.map((a) {
                    final color = _statusColor(a.status);
                    return _buildResultItem(
                      '${a.unit} ${a.value}',
                      dateFmt.format(a.date),
                      _statusLabel(a.status),
                      color,
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
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
                if (status == "high_status".tr() || status == "مرتفع") ...[
                  const SizedBox(width: 4),
                  Icon(Icons.trending_up, color: color, size: 16),
                ],
              ],
            ),
          ),
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
