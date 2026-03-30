import 'package:flutter/material.dart';

class ExpandableCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final String status;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
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

                  /// 🔥 السهم
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_left,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 10),

                  /// 🔥 المحتوى
                  Expanded(
                    child: Row(
                      children: [

                        /// 🔹 الحالة
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: getColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.status,
                            style: TextStyle(
                              color: getColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// 🔹 القيمة + الوحدة
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              widget.unit,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        /// 🔹 اسم التحليل + subtitle
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              "Glucose",
                              style: TextStyle(
                                fontSize: 11,
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "المعدل الطبيعي: 70 - 100 mg/dL",
                      textAlign: TextAlign.right,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// التفسير
                  const Text(
                    "التفسير",
                    style: TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "القيمة ضمن المعدل الطبيعي.",
                    textAlign: TextAlign.right,
                  ),

                  const SizedBox(height: 10),

                  /// التوصيات
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F6F1),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "استمر على نمط حياة صحي.",
                      textAlign: TextAlign.right,
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