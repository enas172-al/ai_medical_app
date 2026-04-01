import 'package:flutter/material.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  List<Map<String, dynamic>> _medications = [
    {
      'name': 'أسبرين',
      'dose': '100 ملغ',
      'time': '08:00 صباحاً',
      'frequency': 'يومياً',
      'color': Colors.blue,
    },
    {
      'name': 'ميتفورمين',
      'dose': '500 ملغ',
      'time': '12:00 ظهراً',
      'frequency': 'يومياً',
      'color': Colors.purple,
    },
    {
      'name': 'فيتامين د',
      'dose': '1000 وحدة',
      'time': '09:00 صباحاً',
      'frequency': 'يومياً',
      'color': Colors.orange,
    },
  ];

  void _deleteMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }
  void _openAddMedication(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddMedicationDialog(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const SizedBox(height: 20),

            ///  العنوان
            const Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(
                    "الأدوية والمكملات",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                   SizedBox(height: 4),
                   Text(
                    "تتبع مواعيد أدويتك ومكملاتك الغذائية",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ///  زر إضافة
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0ED2B1), Color(0xFF1FB6A6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  _openAddMedication(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "إضافة دواء جديد",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.add, size: 22),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 القائمة
            Expanded(
              child: ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final med = _medications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// 🔥 أيقونة (يمين)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: med['color'],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.medication_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 16),

                        /// 🔥 تفاصيل (منتصف)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                med['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                med['dose'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    med['time'],
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.notifications_none_outlined, size: 16, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    med['frequency'],
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        /// 🔥 حذف (يسار)
                        GestureDetector(
                          onTap: () => _deleteMedication(index),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMedicationDialog extends StatefulWidget {
  const AddMedicationDialog({super.key});

  @override
  State<AddMedicationDialog> createState() =>
      _AddMedicationDialogState();
}

class _AddMedicationDialogState
    extends State<AddMedicationDialog> {

  String frequency = "يومياً";

  TimeOfDay? selectedTime;

  ///  اختيار الوقت
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Directionality(
        textDirection: TextDirection.ltr,

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              ///  العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),

                  const Text(
                    "إضافة دواء جديد",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _field("اسم الدواء", "مثال: أسبرين"),
              const SizedBox(height: 12),

              _field("الجرعة", "مثال: 100 ملغ"),
              const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              /// 🔹 العنوان
              const Text(
                "الوقت",
                textAlign: TextAlign.right,
              ),

              const SizedBox(height: 6),

              /// 🔹 الحقل
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      /// الوقت
                      Text(
                        selectedTime == null
                            ? "--:--"
                            : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(width: 6),

                      /// الأيقونة
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

              const SizedBox(height: 12),

              ///  التكرار
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  const Text("التكرار"),

                  const SizedBox(height: 6),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: frequency,
                      isExpanded: true,
                      underline: const SizedBox(),
                      alignment: Alignment.centerRight,
                      items: const [
                        DropdownMenuItem(
                          value: "يومياً",
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("يومياً"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "مرتين يومياً",
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("مرتين يومياً"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "ثلات مرات يومياً",
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("ثلات مرات يومياً"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "أسبوعيا ",
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("أسبوعيا "),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "شهرياً",
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("شهريا"),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          frequency = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ///  زر إضافة
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FB6A6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("اختار الوقت أولاً"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("إضافة"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        Text(label),

        const SizedBox(height: 6),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }
}