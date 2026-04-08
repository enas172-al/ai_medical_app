import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';


class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'أسبرين',
      'dose': '100 ملغ',
      'time': '08:00 صباحاً',
      'frequency': 'يومياً',
      'color': Colors.blue,
      'userName': 'أحمد محمد',
      'entryDateTime': DateTime(2026, 4, 1, 8, 30),
    },
    {
      'name': 'ميتفورمين',
      'dose': '500 ملغ',
      'time': '12:00 ظهراً',
      'frequency': 'يومياً',
      'color': Colors.purple,
      'userName': 'د. سارة علي',
      'entryDateTime': DateTime(2026, 3, 28, 14, 15),
    },
    {
      'name': 'فيتامين د',
      'dose': '1000 وحدة',
      'time': '09:00 صباحاً',
      'frequency': 'يومياً',
      'color': Colors.orange,
      'userName': 'أحمد محمد',
      'entryDateTime': DateTime(2026, 4, 5, 10, 0),
    },
    {
      'name': 'نوبين',
      'dose': '10 ملغ',
      'time': '12:33',
      'frequency': 'ثلاث مرات يومياً',
      'color': Colors.red,
      'image': 'assets/images/nopain_medication.png',
      'userName': 'أحمد محمد',
      'entryDateTime': DateTime(2026, 4, 7, 12, 33),
    },
  ];

  void _deleteMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }
  void _openAddMedication(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Medication",
      pageBuilder: (context, anim1, anim2) => Center(
        child: AddMedicationDialog(
          onAdd: (newMed) {
            setState(() {
              _medications.add(newMed);
            });
          },
        ),
      ),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1,
            child: child,
          ),
        );
      },
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
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: med['image'] != null ? 56 : 48,
                          height: med['image'] != null ? 56 : 48,
                          decoration: BoxDecoration(
                            color: med['image'] != null ? Colors.white : med['color'],
                            borderRadius: BorderRadius.circular(14),
                            border: med['image'] != null ? Border.all(color: Colors.grey.shade200) : null,
                          ),
                          child: med['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: med['image'] is File
                                      ? Image.file(
                                          med['image'] as File,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.asset(
                                          med['image'] as String,
                                          fit: BoxFit.contain,
                                        ),
                                )
                              : const Icon(
                                  Icons.medication_outlined,
                                  color: Colors.white,
                                  size: 26,
                                ),
                        ),

                        const SizedBox(width: 16),

                        /// تفاصيل (منتصف)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.person_outline, size: 14, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    med['userName'] ?? "مجهول",
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    med['entryDateTime'] is DateTime
                                        ? "${(med['entryDateTime'] as DateTime).year}/${(med['entryDateTime'] as DateTime).month.toString().padLeft(2, '0')}/${(med['entryDateTime'] as DateTime).day.toString().padLeft(2, '0')}"
                                        : "-",
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        GestureDetector(
                          onTap: () => _deleteMedication(index),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
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
  final Function(Map<String, dynamic>) onAdd;
  const AddMedicationDialog({super.key, required this.onAdd});

  @override
  State<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  String frequency = "يومياً";
  TimeOfDay? selectedTime;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  DateTime _entryDateTime = DateTime.now();
  File? _selectedImage;
  String? _fileName;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1FB6A6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }



  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _fileName = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _selectedImage = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  void _showImageSourceDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Image Source",
      pageBuilder: (context, anim1, anim2) => Center(
        child: Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sourceOption(
                icon: Icons.insert_photo_outlined,
                label: "مكتبة الصور",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _sourceOption(
                icon: Icons.camera_alt_outlined,
                label: "التقاط صورة",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              _sourceOption(
                icon: Icons.folder_open_outlined,
                label: "اختيار ملف",
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        ),
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _pickEntryDateTime() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Entry Date Time Picker",
      pageBuilder: (context, anim1, anim2) => Center(
        child: CustomDateTimePicker(
          initialDateTime: _entryDateTime,
          onConfirm: (dateTime) {
            setState(() {
              _entryDateTime = dateTime;
            });
          },
        ),
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Text(
                    "إضافة دواء جديد",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 24), // For balance
                ],
              ),
              const SizedBox(height: 24),

              _fieldLabel("اسم الدواء"),
              const SizedBox(height: 8),
              _textField(_nameController, "مثال: أسبرين"),
              const SizedBox(height: 20),

              _fieldLabel("الجرعة"),
              const SizedBox(height: 8),
              _textField(_doseController, "مثال: 100 ملغ"),
              const SizedBox(height: 20),

              _fieldLabel("الوقت"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF9CA3AF), size: 20),
                      const Spacer(),
                      Text(
                        selectedTime == null
                            ? ""
                            : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _fieldLabel("التكرار"),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: frequency,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
                  alignment: Alignment.centerRight,
                  items: ["يومياً", "مرتين يومياً", "ثلات مرات يومياً", "أسبوعيا ", "شهرياً"]
                      .map((String val) => DropdownMenuItem(
                            value: val,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(val, style: const TextStyle(color: Color(0xFF1F2937))),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => frequency = value!),
                ),
              ),
              const SizedBox(height: 20),

              _fieldLabel("اسم الشخص المُدخل"),
              const SizedBox(height: 8),
              _textField(_userNameController, "مثال: أحمد محمد"),
              const SizedBox(height: 20),

              _fieldLabel("تاريخ ووقت الإدخال"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickEntryDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${_entryDateTime.year}/${_entryDateTime.month.toString().padLeft(2, '0')}/${_entryDateTime.day.toString().padLeft(2, '0')} , ${_entryDateTime.hour > 12 ? _entryDateTime.hour - 12 : _entryDateTime.hour}:${_entryDateTime.minute.toString().padLeft(2, '0')} ${_entryDateTime.hour >= 12 ? 'م' : 'ص'}",
                        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF9CA3AF), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _fieldLabel("صورة الدواء"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0ED2B1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedImage != null
                            ? "تم اختيار صورة"
                            : _fileName != null
                                ? "تم اختيار ملف"
                                : "أضف صورة",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Add Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FB6A6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("يرجى إدخال اسم الدواء")),
                      );
                      return;
                    }
                    widget.onAdd({
                      'name': _nameController.text,
                      'dose': _doseController.text,
                      'time': selectedTime == null
                          ? "00:00"
                          : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                      'frequency': frequency,
                      'userName': _userNameController.text.isNotEmpty ? _userNameController.text : "أحمد محمد",
                      'entryDateTime': _entryDateTime,
                      'image': _selectedImage, // Saves the actual File object
                      'color': Colors.teal,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "إضافة",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class CustomDateTimePicker extends StatefulWidget {
  final DateTime initialDateTime;
  final Function(DateTime) onConfirm;

  const CustomDateTimePicker({
    super.key,
    required this.initialDateTime,
    required this.onConfirm,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.initialDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 327,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Calendar View (Simplified version of Month Picker)
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF1FB6A6),
                  onPrimary: Colors.white,
                  surface: Color(0xFF374151),
                  onSurface: Colors.white,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Color(0xFF374151),
                ),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                onDateChanged: (value) => setState(() => _selectedDate = value),
              ),
            ),

            const Divider(color: Color(0xFF4B5563), height: 1),

            /// Time Selector
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFF1FB6A6),
                                onPrimary: Colors.white,
                                surface: Color(0xFF374151),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_selectedTime.hour > 12 ? _selectedTime.hour - 12 : _selectedTime.hour == 0 ? 12 : _selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'م' : 'ص'}",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const Text(
                    "الوقت",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            /// Footer Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    final finalDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );
                    widget.onConfirm(finalDateTime);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1FB6A6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                      _selectedTime = TimeOfDay.now();
                    });
                  },
                  child: const Text(
                    "إعادة تعيين",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
