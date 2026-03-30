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

            ///  العنوان
            const Text(
              "الأدوية والمكملات",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "تتبع مواعيد أدويتك بسهولة",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 20),

            ///  زر إضافة
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1FB6A6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  _openAddMedication(context);
                },
                icon: const Icon(Icons.add),
                label: const Text("إضافة دواء جديد"),
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
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Stack(
                      children: [

                        /// 🔥 الكارد
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 70, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [

                              /// الاسم
                              Text(
                                med['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              /// الجرعة
                              Text(
                                med['dose'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// الوقت
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  Text(
                                    med['frequency'],
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF9CA3AF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    med['time'],
                                    style: const TextStyle(
                                      color: Color(0xFF1FB6A6),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// 🔥 حذف (فوق يسار)
                        Positioned(
                          top: 30,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => _deleteMedication(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        /// 🔥 تعديل (يمين)
                        Positioned(
                          top: 20,
                          right: 12,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: med['color'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
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
            textAlign: TextAlign.left,
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