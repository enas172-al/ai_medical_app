import 'package:flutter/material.dart';

class ExpandableCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String value;
  final String unit;
  final String status;
  final String normalRange;
  final String interpretation;
  final String recommendation;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    required this.status,
    required this.normalRange,
    required this.interpretation,
    required this.recommendation,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool isOpen = false;

  Color getColor() {
    switch (widget.status) {
      case "طبيعي":
        return const Color(0xFF2E7D32);
      case "مرتفع":
        return const Color(0xFFD32F2F);
      case "منخفض":
        return const Color(0xFFF57C00);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [

          /// 🔹 الهيدر
          InkWell(
            onTap: () => setState(() => isOpen = !isOpen),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [

                  /// 🔥 المحتوى
                  Expanded(
                    child: Row(
                      children: [
                        /// 🔹 اسم التحليل + subtitle (On the RIGHT in RTL)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 🔹 القيمة + الوحدة (Middle)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              widget.unit,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        /// 🔹 الحالة (Left of Middle)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: getColor().withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                widget.status,
                                style: TextStyle(
                                  color: getColor(),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.remove, color: getColor(), size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// 🔥 السهم (On the FAR LEFT in RTL)
                  Icon(
                    isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          /// 🔽 التفاصيل
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [

                  /// المعدل الطبيعي
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "المعدل الطبيعي\n${widget.normalRange}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// التفسير
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "التفسير",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1FB6A6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.interpretation,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey.shade800, height: 1.5),
                  ),

                  const SizedBox(height: 15),

                  /// التوصيات
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBFAF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "التوصيات",
                          style: TextStyle(
                              color: Color(0xFF0C5D4F),
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.recommendation,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFF167564),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}