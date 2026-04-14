import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui' as ui;
import '../../core/widgets/custom_app_bar.dart';
import '../analysis/analysis_details_screen.dart';
import '../../core/services/database_service.dart';
import '../../core/models/test_definition_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _db = DatabaseService();
  final _controller = TextEditingController();

  String _query = '';
  Future<Map<String, List<TestDefinitionModel>>>? _future;

  @override
  void initState() {
    super.initState();
    // Load list immediately, then (in background) ensure 500 Mayo Labs tests exist once.
    _future = _db.listTestDefinitionsGrouped(limit: 500);
    _seedOnce();
  }

  Future<void> _seedOnce() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لازم تسجل دخول باش نقدر نعبّي التحاليل في قاعدة البيانات')),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('جارٍ تجهيز التحاليل من المصدر...')),
        );
      }
      final seeded = await _db.ensureMayoLabsSeededOnce(limit: 500);
      if (!mounted) return;
      if (seeded > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تجهيز $seeded تحليل')),
        );
      }
      setState(() {
        _future = _db.listTestDefinitionsGrouped(limit: 500);
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ensureMayoLabsSeededOnce failed: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تجهيز التحاليل: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() {
      _query = v;
      if (v.trim().isEmpty) {
        _future = _db.listTestDefinitionsGrouped(limit: 500);
      } else {
        _future = _db.searchTestDefinitionsGrouped(v);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        /// AppBar
        appBar: const CustomAppBar(
          title: "",
          showBack: true,
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),
                const SizedBox(height: 10),

                ///  Title
                Text(
                  "search_tests_title".tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                /// 📋 Subtitle
                Text(
                  "search_tests_subtitle".tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                ///  Search Box
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _controller,
                    textDirection: Directionality.of(context),
                    onChanged: _onChanged,
                    decoration: InputDecoration(
                      hintText: "search_tests_hint".tr(),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// 📋 List
                Expanded(
                  child: _buildResults(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    return FutureBuilder<Map<String, List<TestDefinitionModel>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          if (kDebugMode) {
            debugPrint('SearchScreen Firestore error: ${snapshot.error}');
          }
          return Center(
            child: Text(
              'حدث خطأ أثناء البحث',
              style: TextStyle(color: Colors.red.shade400),
            ),
          );
        }

        final grouped = snapshot.data ?? {};
        if (grouped.isEmpty) {
          return Center(
            child: Text(
              _query.trim().isEmpty ? 'لا توجد تحاليل بعد' : 'لا توجد نتائج لـ "$_query"',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        final sections = grouped.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: sections.length,
          itemBuilder: (context, idx) {
            final section = sections[idx];
            final category = section.key;
            final items = section.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 10),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ...items.map((t) => _buildTestCardFromModel(context, t)),
                const SizedBox(height: 6),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTestCardFromModel(BuildContext context, TestDefinitionModel t) {
    final isArabic = context.locale.languageCode == 'ar';
    final title = isArabic ? t.nameAr : t.nameEn;
    final subtitle = t.shortCode.isNotEmpty
        ? t.shortCode
        : (t.source == 'mayocliniclabs' ? 'Mayo Labs' : (isArabic ? t.nameEn : t.nameAr));

    String normalRange = '';
    if (t.normalMin != null && t.normalMax != null) {
      normalRange = '${t.normalMin} - ${t.normalMax} ${t.unit}'.trim();
    } else if (t.normalMax != null) {
      normalRange = '<= ${t.normalMax} ${t.unit}'.trim();
    } else if (t.normalMin != null) {
      normalRange = '>= ${t.normalMin} ${t.unit}'.trim();
    } else {
      normalRange = t.unit.isNotEmpty ? t.unit : '-';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisDetailsScreen(
              title: title,
              subtitle: subtitle,
              category: t.category,
              normalRange: normalRange,
              highText: t.highText ?? '',
              lowText: t.lowText ?? '',
              simplifiedExplanation: t.simplifiedExplanation,
              referenceText: t.referenceText,
              sourceUrl: t.sourceUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (normalRange.isNotEmpty && normalRange != '-') ...[
                    Text(
                      normalRange,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.category,
                      style: const TextStyle(
                        color: Color(0xFF1FB6A6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back,
              color: Colors.grey,
              size: 24,
              textDirection: ui.TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}