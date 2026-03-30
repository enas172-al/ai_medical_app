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

  void _addMedication(Map<String, dynamic> newMedication) {
    setState(() {
      _medications.add(newMedication);
    });
  }

  void _deleteMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "الأدوية والمكملات",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const Text(
              "تتبع مواعيد أدويتك بسهولة",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // ➕ زر إضافة
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => AddMedicationSheet(
                      onAdd: _addMedication,
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  "إضافة دواء",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📋 القائمة
            Expanded(
              child: _medications.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "لا توجد أدوية",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "أضف دواءك الأول",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final med = _medications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        // حذف
                        GestureDetector(
                          onTap: () => _deleteMedication(index),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // أيقونة
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: (med['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.medication,
                            color: med['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // النص (على اليمين)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                med['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1F2937),
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                med['dose'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    med['frequency'],
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9CA3AF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    med['time'],
                                    style: const TextStyle(
                                      color: Color(0xFF1FB6A6),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

// صفحة إضافة دواء جديد محسنة
class AddMedicationSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddMedicationSheet({super.key, required this.onAdd});

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _timeController = TextEditingController();
  String _frequency = "يومياً";
  Color _selectedColor = Colors.blue;

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.teal,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1FB6A6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        String period = picked.period == DayPeriod.am ? "صباحاً" : "مساءً";
        _timeController.text =
        "${picked.hourOfPeriod}:${picked.minute.toString().padLeft(2, '0')} $period";
      });
    }
  }

  void _handleAdd() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd({
        'name': _nameController.text,
        'dose': _doseController.text,
        'time': _timeController.text,
        'frequency': _frequency,
        'color': _selectedColor,
      });
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة الدواء بنجاح'),
          backgroundColor: Color(0xFF1FB6A6),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر الإغلاق
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // العنوان
                const Center(
                  child: Text(
                    "إضافة دواء جديد",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // اسم الدواء
                const Text(
                  "اسم الدواء",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 6),
                _inputField(
                  hint: "مثال: أسبرين",
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الدواء';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // الجرعة
                const Text(
                  "الجرعة",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 6),
                _inputField(
                  hint: "مثال: 100 ملغ",
                  controller: _doseController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الجرعة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // الوقت
                const Text(
                  "الوقت",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 6),
                _inputField(
                  hint: "اختر الوقت",
                  controller: _timeController,
                  icon: Icons.access_time,
                  readOnly: true,
                  onTap: _selectTime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الوقت';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // التكرار
                const Text(
                  "التكرار",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _frequency,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    items: const [
                      DropdownMenuItem(value: "يومياً", child: Text("يومياً")),
                      DropdownMenuItem(value: "أسبوعياً", child: Text("أسبوعياً")),
                      DropdownMenuItem(value: "شهرياً", child: Text("شهرياً")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _frequency = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // لون الأيقونة
                const Text(
                  "لون الأيقونة",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Row(
                  children: _colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: _selectedColor == color
                              ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // زر الإضافة
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1FB6A6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _handleAdd,
                    child: const Text(
                      "إضافة الدواء",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      textAlign: TextAlign.right,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF9CA3AF))
            : null,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1FB6A6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}