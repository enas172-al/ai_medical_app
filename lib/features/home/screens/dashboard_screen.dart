import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../results/view/screens/analysis_detail_screen.dart';
import '../../../core/models/analysis_model.dart';
import '../../../core/models/app_notification_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/notifications_repository.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const DashboardScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final userName = (user?.displayName?.trim().isNotEmpty == true)
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first.trim().isNotEmpty == true)
            ? user!.email!.split('@').first.trim()
            : "anonymous_user".tr();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
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
                _buildTitleSection(userName: userName),

                const SizedBox(height: 10),

                // 4. General Status (الحالة العامة)
                _buildGeneralStatusSection(userId: userId),

                const SizedBox(height: 25),

                // 5. Alerts Section (التنبيهات)
                _buildAlertsSection(userId: userId),

                const SizedBox(height: 25),

                // 6. Chart Section (الرسم البياني)
                DashboardInteractiveChart(userId: userId),

                const SizedBox(height: 25),

                // 7. Latest Analysis (آخر التحاليل)
                _buildLatestAnalysisSection(context, userId: userId),

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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937), size: 24),
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
            Image.asset('assets/images/logo.png', width: 56, height: 56),
            const SizedBox(height: 12),
            Text(
              "app_title".tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection({required String userName}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Text(
              "dashboard_title".tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "welcome_user".tr(args: [userName]),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStatusSection({required String? userId}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "general_status".tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.edit_note, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          if (userId == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "history_sign_in".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            StreamBuilder<List<AnalysisModel>>(
              stream: DatabaseService().getAnalyses(userId),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final list = snap.data ?? const <AnalysisModel>[];
                final status = _computeGeneralStatus(list);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: status.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        status.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: status.fg,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status.subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8C8C8C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection({required String? userId}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "alerts".tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          if (userId == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "history_sign_in".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            StreamBuilder<List<AppNotificationModel>>(
              stream: NotificationsRepository().watchForUser(userId, limit: 3),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final list = snap.data ?? const <AppNotificationModel>[];
                if (list.isEmpty) {
                  return Text(
                    "no_data_found".tr(),
                    style: const TextStyle(color: Colors.grey),
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < list.length; i++) ...[
                      _buildAlertCardFromNotification(list[i]),
                      if (i != list.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              },
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

  Widget _buildChartSection({required String? userId}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "chart".tr(),
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
                    _buildFilterButton("year".tr(), false),
                    const SizedBox(width: 8),
                    _buildFilterButton("month".tr(), false),
                    const SizedBox(width: 8),
                    _buildFilterButton("week".tr(), true),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "sugar_level_7days".tr(),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (userId == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "history_sign_in".tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  FutureBuilder<List<AnalysisModel>>(
                    future: DatabaseService().getAnalysesOnce(userId),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final list = snap.data ?? const <AnalysisModel>[];
                      final points = _buildSugarSeries(list);
                      if (points.isEmpty) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              "no_data_found".tr(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 200,
                        child: LineChart(_sugarLevelData(points)),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem("actual_value".tr(), const Color(0xFF1FB6A6), true),
                    const SizedBox(width: 20),
                    _buildLegendItem("target".tr(), Colors.orange, false),
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

  LineChartData _sugarLevelData(List<FlSpot> spots) {
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
              final days = [
                "friday".tr(),
                "wednesday".tr(),
                "tuesday".tr(),
                "monday".tr(),
                "sunday".tr(),
                "saturday".tr()
              ];
              int index = value.toInt();
              if (index >= 0 && index < days.length) {
                return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(days[index],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)));
              }
              return Text("");
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
      maxX: (spots.length - 1).toDouble().clamp(1, 30),
      minY: 0,
      maxY: 120,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
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
          spots: [
            FlSpot(0, 80),
            FlSpot((spots.length - 1).toDouble().clamp(1, 30), 80),
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

  Widget _buildLatestAnalysisSection(BuildContext context, {required String? userId}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "latest_analysis".tr(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.edit, color: Colors.green, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (userId == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "history_sign_in".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            StreamBuilder<List<AnalysisModel>>(
              stream: DatabaseService().getAnalyses(userId),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final list = snap.data ?? const <AnalysisModel>[];
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "history_empty".tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final top = list.take(3).toList();
                return Column(
                  children: [
                    for (final a in top)
                      _buildAnalysisItemFromModel(context, a),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  static String _formatShortDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  static String _localizedStatus(String raw) {
    final s = raw.trim().toLowerCase();
    if (s == 'high') return "high_status".tr();
    if (s == 'low') return "low_status".tr();
    return "normal_status".tr();
  }

  static ({Color fg, Color bg, Color border, IconData icon}) _statusPalette(String localizedStatus) {
    if (localizedStatus == "high_status".tr()) {
      return (fg: const Color(0xFFF5222D), bg: const Color(0xFFFFF1F0), border: const Color(0xFFFFA39E), icon: Icons.warning_amber_rounded);
    }
    if (localizedStatus == "low_status".tr()) {
      return (fg: const Color(0xFFFAAD14), bg: const Color(0xFFFFF7E6), border: const Color(0xFFFFD591), icon: Icons.report_problem_outlined);
    }
    return (fg: const Color(0xFF52C41A), bg: const Color(0xFFF6FFED), border: const Color(0xFFB7EB8F), icon: Icons.check_circle_outline);
  }

  Widget _buildAnalysisItemFromModel(BuildContext context, AnalysisModel a) {
    final status = _localizedStatus(a.status);
    final pal = _statusPalette(status);
    return _buildAnalysisItem(
      context,
      a.testName,
      _formatShortDate(a.date),
      status,
      a.value.toString(),
      a.unit,
      pal.fg,
      pal.bg,
      pal.icon,
    );
  }

  static List<FlSpot> _buildSugarSeries(List<AnalysisModel> all) {
    // Try to find glucose/sugar results from existing analyses.
    final filtered = all.where((a) {
      final name = a.testName.toLowerCase();
      return name.contains('glucose') || name.contains('sugar') || name.contains('سكر');
    }).toList();
    final list = (filtered.isNotEmpty ? filtered : all).take(6).toList().reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < list.length; i++) {
      final v = list[i].value;
      if (v.isNaN) continue;
      spots.add(FlSpot(i.toDouble(), v.clamp(0, 500)));
    }
    return spots;
  }

  Widget _buildAlertCardFromNotification(AppNotificationModel n) {
    final t = n.type.trim().toLowerCase();
    final isMedication = t.contains('med');
    final isAnalysis = t.contains('analysis') || t.contains('lab');

    final icon = isMedication
        ? Icons.medication_outlined
        : isAnalysis
            ? Icons.science_outlined
            : Icons.notifications_none;

    final color = isMedication
        ? const Color(0xFFFAAD14)
        : isAnalysis
            ? const Color(0xFF1890FF)
            : const Color(0xFF1FB6A6);

    final bgColor = isMedication
        ? const Color(0xFFFFF7E6)
        : isAnalysis
            ? const Color(0xFFE6F7FF)
            : const Color(0xFFEFFBF9);

    final borderColor = isMedication
        ? const Color(0xFFFFD591)
        : isAnalysis
            ? const Color(0xFF91D5FF)
            : const Color(0xFFB2DFDB);

    return _buildAlertCard(
      title: n.title.isNotEmpty ? n.title : "alerts".tr(),
      subtitle: n.body,
      icon: icon,
      color: color,
      bgColor: bgColor,
      borderColor: borderColor,
    );
  }

  static ({String title, String subtitle, Color fg, Color bg, Color border}) _computeGeneralStatus(
    List<AnalysisModel> list,
  ) {
    // If there is any High/Low in last 30 days → "needs_slight_attention", else if there are analyses → Normal.
    final now = DateTime.now();
    final recent = list.where((a) => now.difference(a.date).inDays <= 30).toList();
    final hasAbnormal = recent.any((a) {
      final s = a.status.trim().toLowerCase();
      return s == 'high' || s == 'low';
    });

    if (list.isEmpty) {
      return (
        title: "no_data_found".tr(),
        subtitle: "history_empty".tr(),
        fg: const Color(0xFF8C8C8C),
        bg: const Color(0xFFF5F5F5),
        border: const Color(0xFFE0E0E0),
      );
    }

    if (hasAbnormal) {
      return (
        title: "needs_slight_attention".tr(),
        subtitle: "mostly_normal_some_notes".tr(),
        fg: const Color(0xFFD48806),
        bg: const Color(0xFFFFFBE6),
        border: const Color(0xFFFFE58F),
      );
    }

    return (
      title: "normal_status".tr(),
      subtitle: "analysis_success".tr(),
      fg: const Color(0xFF2E7D32),
      bg: const Color(0xFFF6FFED),
      border: const Color(0xFFB7EB8F),
    );
  }

  Widget _buildAnalysisItem(
      BuildContext context,
      String title,
      String date,
      String status,
      String value,
      String unit,
      Color statusColor,
      Color statusBg,
      IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisDetailScreen(
              name: title,
              value: value,
              unit: unit,
              status: status,
              date: date,
              statusColor: statusColor,
            ),
          ),
        );
      },
      child: Container(
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
            // الأيقونة (أقصى اليسار)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: statusBg, shape: BoxShape.circle),
              child: Icon(icon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 15),
            // الاسم والتاريخ (جهة اليسار)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.grey, size: 12),
                    const SizedBox(width: 4),
                    Text(date,
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const Spacer(), // يدفع الحالة والسهم لليمين
            // الحالة (جهة اليمين)
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
            // السهم (أقصى اليمين)
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "advice_section_title".tr(),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Color(0xFFD48806), shape: BoxShape.circle),
                      child:
                      const Icon(Icons.bolt, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "advice_of_the_day".tr(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD48806)),
                    ),


                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "drink_water_advice".tr(),
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

class DashboardInteractiveChart extends StatefulWidget {
  final String? userId;
  const DashboardInteractiveChart({super.key, required this.userId});

  @override
  State<DashboardInteractiveChart> createState() => _DashboardInteractiveChartState();
}

class _DashboardInteractiveChartState extends State<DashboardInteractiveChart> {
  String? _selectedTest;
  late Future<List<AnalysisModel>> _futureAnalyses;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _futureAnalyses = DatabaseService().getAnalysesOnce(widget.userId!);
    } else {
      _futureAnalyses = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "chart".tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.auto_graph, color: Colors.redAccent),
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
            child: widget.userId == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "history_sign_in".tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : FutureBuilder<List<AnalysisModel>>(
                    future: _futureAnalyses,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final allList = snap.data ?? const <AnalysisModel>[];
                      
                      final uniqueTests = allList.map((e) => e.testName).toSet().toList();
                      if (uniqueTests.isEmpty) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              "no_data_found".tr(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      if (_selectedTest == null || !uniqueTests.contains(_selectedTest)) {
                        _selectedTest = uniqueTests.first;
                      }

                      final now = DateTime.now();
                      final filteredList = allList.where((a) {
                        return a.testName == _selectedTest && now.difference(a.date).inDays <= 7;
                      }).toList().reversed.toList();

                      final spots = <FlSpot>[];
                      for (int i = 0; i < filteredList.length; i++) {
                        final v = filteredList[i].value;
                        if (!v.isNaN) {
                          spots.add(FlSpot(i.toDouble(), v));
                        }
                      }

                      double maxY = 120;
                      if (spots.isNotEmpty) {
                         double maxVal = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
                         maxY = (maxVal > 0 ? maxVal * 1.5 : 100);
                      }

                      return Column(
                        children: [
                          // Filter buttons omitted as per user request
                          Align(
                            alignment: Alignment.centerRight,
                            child: DropdownButton<String>(
                              value: _selectedTest,
                              isExpanded: false,
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1F2937)),
                              dropdownColor: Colors.white,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1FB6A6),
                              ),
                              items: uniqueTests.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedTest = val;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (spots.isEmpty)
                            SizedBox(
                              height: 200,
                              child: Center(
                                child: Text(
                                  "no_data_found".tr(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 200,
                              child: LineChart(_chartData(spots, maxY)),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem("actual_value".tr(), const Color(0xFF1FB6A6), true),
                            ],
                          ),
                        ],
                      );
                    },
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

  LineChartData _chartData(List<FlSpot> spots, double maxY) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (maxY / 4) > 0 ? (maxY / 4) : 10,
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
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final days = [
                "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"
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
            interval: (maxY / 4) > 0 ? (maxY / 4) : 10,
            getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (spots.length - 1).toDouble().clamp(1, 7),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: const Color(0xFF1FB6A6),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF1FB6A6).withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

