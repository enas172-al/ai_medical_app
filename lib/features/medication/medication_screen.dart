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
  String _currentUser = 'محمد أحمد';
  String _loggedInUser = 'محمد أحمد';
  String _loggedInUserRole = 'مرافق';

  final List<Map<String, dynamic>> _accounts = [
    {
      'name': 'أحمد محمد',
      'type': 'dependent',
      'age': '65 سنة',
      'tag': 'عضو في العائلة',
    },
    {
      'name': 'محمد أحمد',
      'type': 'personal',
      'age': '35 سنة',
      'tag': 'حسابي',
    },
  ];

  final List<Map<String, dynamic>> _medications = [
    {
      'id': '1',
      'name': 'أسبرين',
      'dose': '100 ملغ',
      'time': '08:00 صباحاً',
      'frequency': 'يومياً',
      'color': Colors.blue,
      'userName': 'أحمد محمد',
      'entryDateTime': DateTime(2026, 4, 1, 8, 30),
    },
    {
      'id': '2',
      'name': 'ميتفورمين',
      'dose': '500 ملغ',
      'time': '12:00 ظهراً',
      'frequency': 'يومياً',
      'color': Colors.purple,
      'userName': 'د. سارة علي',
      'entryDateTime': DateTime(2026, 3, 28, 14, 15),
    },
    {
      'id': '3',
      'name': 'فيتامين د',
      'dose': '1000 وحدة',
      'time': '09:00 صباحاً',
      'frequency': 'يومياً',
      'color': Colors.orange,
      'userName': 'أحمد محمد',
      'entryDateTime': DateTime(2026, 4, 5, 10, 0),
    },
    {
      'id': '4',
      'name': 'نوبين',
      'dose': '10 ملغ',
      'time': '12:33',
      'frequency': 'ثلاث مرات يومياً',
      'color': Colors.red,
      'userName': 'أحمد محمد',
      'entryDateTime': DateTime(2026, 4, 7, 12, 33),
    },
    {
      'id': '5',
      'name': 'فيتامين سي',
      'dose': '1000 ملغ',
      'time': '09:00 صباحاً',
      'frequency': 'يومياً',
      'color': Colors.green,
      'userName': 'محمد أحمد',
      'entryDateTime': DateTime(2026, 4, 8, 9, 0),
    },
    {
      'id': '6',
      'name': 'أوميجا 3',
      'dose': 'كبسولة واحدة',
      'time': '02:00 ظهراً',
      'frequency': 'يومياً',
      'color': Colors.amber,
      'userName': 'محمد أحمد',
      'entryDateTime': DateTime(2026, 4, 8, 14, 0),
    },
  ];

  int _timeToMinutes(String timeStr) {
    try {
       final str = timeStr.trim().replaceAll('ص', 'صباحاً').replaceAll('م', 'مساءً');
       final parts = str.split(' ');
       final timeParts = parts[0].split(':');
       int h = int.parse(timeParts[0]);
       int m = int.parse(timeParts[1]);
       
       if (parts.length > 1) {
         if ((parts[1].contains('ظهر') || parts[1].contains('مساء')) && h != 12) h += 12;
         if (parts[1].contains('صباح') && h == 12) h = 0;
       }
       return h * 60 + m;
    } catch(e) {
      return 0;
    }
  }

  void _deleteMedication(Map<String, dynamic> med) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: const Text("هل أنت متأكد من حذف هذا الدواء؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _medications.removeWhere((m) => m['id'] == med['id'] || m == med);
                });
                Navigator.pop(context);
              },
              child: const Text("حذف", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddMedication(BuildContext context, {Map<String, dynamic>? initialMed}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Medication",
      pageBuilder: (context, anim1, anim2) => Center(
        child: AddMedicationDialog(
          initialMed: initialMed,
          onAdd: (newMed) {
            setState(() {
              if (initialMed != null) {
                int index = _medications.indexWhere((m) => m['id'] == initialMed['id'] || m == initialMed);
                if (index != -1) {
                  newMed['id'] = initialMed['id'];
                  _medications[index] = newMed;
                }
              } else {
                newMed['id'] = DateTime.now().millisecondsSinceEpoch.toString();
                _medications.add(newMed);
              }
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

  void _showLinkAccountDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Link Account",
      pageBuilder: (context, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("ربط حساب عائلي", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.grey, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("أدخل كود العائلة", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const TextField(
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        hintText: "FAM-2026-XXXXXX",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1FB6A6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الربط بنجاح')));
                      },
                      child: const Text("ربط الحساب", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: ScaleTransition(scale: anim1, child: child));
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
          textDirection: TextDirection.rtl,
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
                const Text("اختر الحساب", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                const Text("اختر من تريد متابعته", style: TextStyle(fontSize: 16, color: Colors.grey)),
                
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
                                    const Text("أنت مسجل الدخول كـ", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
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
                        const Text("الحسابات المتاحة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
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
                            child: const Text("العودة للملف الشخصي", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    List<Map<String, dynamic>> filteredMeds = List.from(_medications);
    filteredMeds.sort((a, b) => _timeToMinutes(a['time']).compareTo(_timeToMinutes(b['time'])));

    var currentUserObj = _accounts.firstWhere((u) => u['name'] == _currentUser, orElse: () => {'name': _currentUser, 'type': 'dependent'});
    bool isPersonal = currentUserObj['type'] == 'personal';

    return Directionality(
      textDirection: TextDirection.rtl,
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
                              Text(isPersonal ? "الحساب الشخصي" : "أنت تتابع", style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
                          child: const Text("تبديل الحساب", style: TextStyle(fontWeight: FontWeight.bold)),
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
                        isPersonal ? "الأدوية والمكملات" : "أدوية $_currentUser",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                       const SizedBox(height: 4),
                       const Text(
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 22),
                        SizedBox(width: 8),
                        Text(
                          "إضافة دواء جديد",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 القائمة
                Expanded(
                  child: filteredMeds.isEmpty 
                    ? const Center(
                        child: Text(
                          "لا توجد أدوية",
                          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredMeds.length,
                        itemBuilder: (context, index) {
                          final med = filteredMeds[index];
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
                                  child: Image.file(
                                    med['image'] is File ? med['image'] : File(med['image'].toString()),
                                    fit: BoxFit.cover,
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
                                    med['time'].replaceAll('ص', 'صباحاً').replaceAll('م', 'مساءً'),
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
              ),
            ),
          ],
        ),
      ),
    ),
  )
    );
}
}

class AddMedicationDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? initialMed;
  const AddMedicationDialog({super.key, required this.onAdd, this.initialMed});

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

  @override
  void initState() {
    super.initState();
    if (widget.initialMed != null) {
      _nameController.text = widget.initialMed!['name'] ?? '';
      _doseController.text = widget.initialMed!['dose'] ?? '';
      _userNameController.text = widget.initialMed!['userName'] ?? '';
      frequency = widget.initialMed!['frequency'] ?? "يومياً";
      _entryDateTime = widget.initialMed!['entryDateTime'] is DateTime ? widget.initialMed!['entryDateTime'] : DateTime.now();
      
      try {
        String t = widget.initialMed!['time'].toString().trim().replaceAll('ص', 'صباحاً').replaceAll('م', 'مساءً');
        final parts = t.split(' ');
        final timeParts = parts[0].split(':');
        int h = int.parse(timeParts[0]);
        int m = int.parse(timeParts[1]);
         
        if (parts.length > 1) {
          if ((parts[1].contains('ظهر') || parts[1].contains('مساء')) && h != 12) h += 12;
          if (parts[1].contains('صباح') && h == 12) h = 0;
        }
        selectedTime = TimeOfDay(hour: h, minute: m);
      } catch (e) {
        selectedTime = null;
      }

      if (widget.initialMed!['image'] != null) {
        if (widget.initialMed!['image'] is File) {
          _selectedImage = widget.initialMed!['image'];
        } else {
          _selectedImage = File(widget.initialMed!['image'].toString());
        }
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
                  Text(
                    widget.initialMed != null ? "تعديل الدواء" : "إضافة دواء جديد",
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
                          : "${selectedTime!.hour > 12 ? selectedTime!.hour - 12 : selectedTime!.hour == 0 ? 12 : selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.hour >= 12 ? 'م' : 'ص'}",
                      'frequency': frequency,
                      'userName': _userNameController.text.isNotEmpty ? _userNameController.text : "أحمد محمد",
                      'entryDateTime': _entryDateTime,
                      'image': _selectedImage, // Saves the actual File object
                      'color': Colors.teal,
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    widget.initialMed != null ? "حفظ التعديلات" : "إضافة",
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
