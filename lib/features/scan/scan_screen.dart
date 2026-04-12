import 'package:flutter/material.dart';
import 'screens/scan_results_screen.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,

        body: SafeArea(
          child: Column(
              children: [

          ///  Header
          Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// Close
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.close, color: Colors.white),
              ),

              const Text(
                "تصوير التحاليل",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 24),
            ],
          ),
        ),

        const SizedBox(height: 10),

        /// الكارد
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [

              ///النص
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "ضع ورقة التحاليل داخل الإطار وتأكد من وضوح النص",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              ///  الإطار
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1FB6A6),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white38,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        ///  الأزرار
        Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

              ///  Gallery
              CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white10,
              child: const Icon(Icons.image, color: Colors.white),
            ),


            GestureDetector(
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanResultsScreen()),
                    );
                },
                child: Container(
                  width: 70,
                  height: 70,decoration: BoxDecoration(
                  color: const Color(0xFF1FB6A6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                ),
            ),

                /// ⚡ Flash
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white10,
                  child: const Icon(Icons.flash_on, color: Colors.white),
                ),
              ],
            ),
        ),
              ],
          ),
        ),
    );
  }
}
