import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/services/database_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/medication_model.dart';


class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final DatabaseService _databaseService = DatabaseService();

  String _currentUser = 'example_name'.tr();
  String _loggedInUser = 'example_name'.tr();
  String _loggedInUserRole = 'companion_role'.tr();

  final List<Map<String, dynamic>> _accounts = [
    {
      'name': 'example_family_member_2'.tr(),
      'type': 'dependent',
      'age': 'years_old'.tr(args: ['65']),
      'tag': 'family_member_tag'.tr(),
    },
    {
      'name': 'example_name'.tr(),
      'type': 'personal',
      'age': 'years_old'.tr(args: ['35']),
      'tag': 'my_account_tag'.tr(),
    },
  ];

  void _deleteMedication(MedicationModel med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("confirm_delete".tr()),
        content: Text("confirm_delete_msg".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr(), style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (med.id != null) {
                await NotificationService.instance.cancelMedicationReminders(med.id);
                // Do not delete from DB; just archive/hide from list.
                await _databaseService.updateMedicationStatus(med.id!, false);
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text("delete".tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openAddMedication(BuildContext context, {MedicationModel? initialMed}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "add_new_med".tr(),
      pageBuilder: (context, anim1, anim2) => Center(
        child: AddMedicationDialog(
          initialMed: initialMed,
          onAdd: (newMedData) async {
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid == null) {
              throw Exception('login_to_save_results'.tr());
            }
            await NotificationService.instance.requestPermissionsIfNeeded();
            final med = MedicationModel(
              id: initialMed?.id,
              userId: uid,
              name: newMedData['name'],
              dosage: newMedData['dose'],
              times: [newMedData['time']],
              daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
              createdAt: initialMed?.createdAt ?? DateTime.now(),
            );

            // Prevent duplicates (same normalized name + dosage + time) among active meds.
            final existing = await _databaseService.getMedicationsOnce(uid, includeInactive: false);
            final newNameKey = DatabaseService.normalizeMedicationKey(med.name);
            final newDoseKey = DatabaseService.normalizeMedicationKey(med.dosage);
            final newTimeKey = med.times.isNotEmpty ? DatabaseService.normalizeMedicationKey(med.times.first) : '';
            final isDup = existing.any((m) {
              if (initialMed?.id != null && m.id == initialMed!.id) return false;
              final nameKey = DatabaseService.normalizeMedicationKey(m.name);
              final doseKey = DatabaseService.normalizeMedicationKey(m.dosage);
              final timeKey = m.times.isNotEmpty ? DatabaseService.normalizeMedicationKey(m.times.first) : '';
              return nameKey == newNameKey && doseKey == newDoseKey && timeKey == newTimeKey;
            });
            if (isDup) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("هذا الدواء موجود بالفعل في القائمة")),
                );
              }
              return;
            }

            final id = await _databaseService.saveMedication(med);
            if (med.times.isNotEmpty) {
              await NotificationService.instance.scheduleMedicationReminders(
                medId: id,
                medicationName: med.name,
                times: med.times,
              );
            }
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

  void _showUserSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F9F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 32),
                
                /// Header Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0ED2B1), Color(0xFF1FB6A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1FB6A6).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                
                /// Title
                Text("select_account".tr(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text("choose_who_to_track".tr(), style: const TextStyle(fontSize: 16, color: Colors.grey)),
                
                const SizedBox(height: 32),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Logged In Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text("you_are_logged_in_as".tr(), style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Text(_loggedInUser, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                                    const SizedBox(height: 4),
                                    Text(_loggedInUserRole, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1FB6A6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.face, color: Colors.white, size: 36),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        Text("available_accounts".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                        const SizedBox(height: 16),
                        
                        /// Accounts List
                        ..._accounts.map((acc) {
                          bool isSelected = acc['name'] == _currentUser;
                          bool isPersonal = acc['type'] == 'personal';
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentUser = acc['name'];
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1FB6A6) : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1.5,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: const Color(0xFF1FB6A6).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))
                                ] : [],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1FB6A6),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(isPersonal ? Icons.face : Icons.elderly, color: Colors.white, size: 36),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(acc['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                        const SizedBox(height: 6),
                                        Text(acc['age'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isPersonal ? const Color(0xFF1FB6A6) : const Color(0xFFF3E8FF),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(isPersonal ? Icons.person_outline : Icons.family_restroom, 
                                                   size: 14, 
                                                   color: isPersonal ? Colors.white : const Color(0xFF7C3AED)),
                                              const SizedBox(width: 6),
                                              Text(acc['tag'], style: TextStyle(
                                                fontSize: 12, 
                                                fontWeight: FontWeight.bold,
                                                color: isPersonal ? Colors.white : const Color(0xFF7C3AED)
                                              )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1FB6A6),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.arrow_back_ios_new, color: Colors.grey, size: 16),
                                ],
                              ),
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 16),
                        
                        /// Return Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F2937),
                              elevation: 0,
                              side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text("return_to_profile".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentUserObj = _accounts.firstWhere((u) => u['name'] == _currentUser, orElse: () => {'name': _currentUser, 'type': 'dependent'});
    bool isPersonal = currentUserObj['type'] == 'personal';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Switch User Header (Hidden if it's the personal account)
                if (!isPersonal) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPersonal 
                            ? [const Color(0xFF0ED2B1), const Color(0xFF1FB6A6)]
                            : [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(isPersonal ? Icons.person : Icons.elderly, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isPersonal ? "personal_account".tr() : "you_are_tracking".tr(), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              Text(_currentUser, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _showUserSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withAlpha(50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text("switch_account_btn".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ]
                    )
                  ),
                  const SizedBox(height: 20),
                ],

                ///  العنوان
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        isPersonal ? "medications_title".tr() : "user_medications_title".tr(args: [_currentUser]),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                       const SizedBox(height: 4),
                       Text(
                        "medications_subtitle".tr(),
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.start,
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
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          "add_new_med".tr(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 القائمة
                Expanded(
                  child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, authSnap) {
                      final uid = authSnap.data?.uid;
                      if (uid == null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              "history_sign_in".tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return StreamBuilder<List<MedicationModel>>(
                        stream: _databaseService.getMedications(uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  '${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),
                            );
                          }

                          final meds = snapshot.data ?? [];

                          if (meds.isEmpty) {
                            return Center(
                              child: Text(
                                "no_meds".tr(),
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: meds.length,
                            itemBuilder: (context, index) {
                              final med = meds[index];
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
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.teal,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.medication_outlined,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            med.name,
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
                                            med.dosage,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.access_time,
                                                  size: 16, color: Color(0xFF9CA3AF)),
                                              const SizedBox(width: 4),
                                              Text(
                                                med.times.isNotEmpty ? med.times.first : "--:--",
                                                style: const TextStyle(
                                                  color: Color(0xFF9CA3AF),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.notifications_none_outlined,
                                                  size: 16, color: Color(0xFF9CA3AF)),
                                              const SizedBox(width: 4),
                                              Text(
                                                "daily".tr(),
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
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _openAddMedication(context, initialMed: med),
                                          child: Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withAlpha(20),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.blue,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _deleteMedication(med),
                                          child: Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: Colors.red.withAlpha(20),
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
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddMedicationDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onAdd;
  final MedicationModel? initialMed;
  const AddMedicationDialog({super.key, required this.onAdd, this.initialMed});

  @override
  State<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  bool _saving = false;
  String frequency = "daily";
  TimeOfDay? selectedTime;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  DateTime _entryDateTime = DateTime.now();
  File? _selectedImage;
  String? _fileName;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialMed != null) {
      _nameController.text = widget.initialMed!.name;
      _doseController.text = widget.initialMed!.dosage;
      // Note: userName mapping is not straightforward as MedicationModel doesn't have it directly stored in the way the initial UI had.
      frequency = "daily"; // Defaulting or mapping if you had specific logic.
      _entryDateTime = DateTime.now();
      
      try {
        if (widget.initialMed!.times.isNotEmpty) {
          String t = widget.initialMed!.times.first.trim().replaceAll('ص', 'صباحاً').replaceAll('م', 'مساءً');
          final parts = t.split(' ');
          final timeParts = parts[0].split(':');
          int h = int.parse(timeParts[0]);
          int m = int.parse(timeParts[1]);
           
          if (parts.length > 1) {
            if ((parts[1].contains('ظهر') || parts[1].contains('مساء')) && h != 12) h += 12;
            if (parts[1].contains('صباح') && h == 12) h = 0;
          }
          selectedTime = TimeOfDay(hour: h, minute: m);
        }
      } catch (e) {
        selectedTime = null;
      }
    }
  }

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
                label: "image_library".tr(),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _sourceOption(
                icon: Icons.camera_alt_outlined,
                label: "capture_image".tr(),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              _sourceOption(
                icon: Icons.folder_open_outlined,
                label: "choose_file".tr(),
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
                  Text(
                    widget.initialMed != null ? "edit_medication".tr() : "add_new_medication".tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 24), // For balance
                ],
              ),
              const SizedBox(height: 24),

              _fieldLabel("med_name".tr()),
              const SizedBox(height: 8),
              _textField(_nameController, "example_med_hint".tr()),
              const SizedBox(height: 20),

              _fieldLabel("dose".tr()),
              const SizedBox(height: 8),
              _textField(_doseController, "example_dose_hint".tr()),
              const SizedBox(height: 20),

              _fieldLabel("time".tr()),
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

              _fieldLabel("frequency".tr()),
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
                  items: ["daily", "twice_daily", "three_times_daily", "weekly", "monthly"]
                      .map((String val) => DropdownMenuItem(
                            value: val,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(val.tr(), style: const TextStyle(color: Color(0xFF1F2937))),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => frequency = value!),
                ),
              ),
              const SizedBox(height: 20),

              _fieldLabel("person_name".tr()),
              const SizedBox(height: 8),
              _textField(_userNameController, "example_user_hint".tr()),
              const SizedBox(height: 20),

              _fieldLabel("entry_date_time".tr()),
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
                        "${_entryDateTime.year}/${_entryDateTime.month.toString().padLeft(2, '0')}/${_entryDateTime.day.toString().padLeft(2, '0')} , ${_entryDateTime.hour > 12 ? _entryDateTime.hour - 12 : _entryDateTime.hour}:${_entryDateTime.minute.toString().padLeft(2, '0')} ${_entryDateTime.hour >= 12 ? 'pm_label'.tr() : 'am_label'.tr()}",
                        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF9CA3AF), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _fieldLabel("med_image".tr()),
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
                            ? "image_selected".tr()
                            : _fileName != null
                                ? "file_selected".tr()
                                : "add_image".tr(),
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
                  onPressed: _saving
                      ? null
                      : () async {
                          if (_nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("enter_med_name_error".tr())),
                            );
                            return;
                          }
                          setState(() => _saving = true);
                          try {
                            await widget.onAdd({
                              'name': _nameController.text,
                              'dose': _doseController.text,
                              'time': selectedTime == null
                                  ? "00:00"
                                  : "${selectedTime!.hour > 12 ? selectedTime!.hour - 12 : selectedTime!.hour == 0 ? 12 : selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.hour >= 12 ? 'pm_label'.tr() : 'am_label'.tr()}",
                              'frequency': frequency,
                              'userName': _userNameController.text.isNotEmpty
                                  ? _userNameController.text
                                  : "أحمد محمد",
                              'entryDateTime': _entryDateTime,
                              'image': _selectedImage,
                              'color': Colors.teal,
                            });
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          } finally {
                            if (context.mounted) setState(() => _saving = false);
                          }
                        },
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "save_btn".tr(),
                          style: const TextStyle(
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
                        "${_selectedTime.hour > 12 ? _selectedTime.hour - 12 : _selectedTime.hour == 0 ? 12 : _selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'pm_label'.tr() : 'am_label'.tr()}",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  Text(
                    "time".tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
                  child: Text(
                    "reset".tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
