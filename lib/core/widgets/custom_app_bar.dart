import 'package:flutter/material.dart';
import '../../features/notifications/notification_sheet.dart';
import '../../features/search/search_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isHome;
  final int notificationCount;
  final bool showBack;

  const CustomAppBar({
    super.key,
    this.title,
    this.isHome = false,
    this.notificationCount = 2,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Material(
          color: Colors.white,
          elevation: 1.5,
          child: SafeArea(
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: showBack
              /// 🟢 حالة صفحة البحث
                  ? Row(
                children: [


                  /// اليمين (logo + labby)
                  Row(
                    children: [

                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "labby",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )

              /// 🟢 باقي الصفحات (كما كان)
                  : Row(
                children: [

                  /// السهم (لو موجود)
                  showBack
                      ? IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => Navigator.pop(context),
                  )
                      : const SizedBox(width: 8),

                  /// اللوقو
                  Image.asset(
                    'assets/images/logo.png',
                    width: 45,
                    height: 45,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),

                  const SizedBox(width: 20),

                  /// النص
                  const Text(
                    "labby",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  /// العنوان أو الأيقونات
                  const Spacer(),
                  isHome
                      ? Row(
                    children: [
                      _buildNotificationIcon(context),
                      _buildIcon(context, Icons.search),
                    ],
                  )
                      : Text(
                    title ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔔 إشعارات
  Widget _buildNotificationIcon(BuildContext context) {
    return Stack(
      children: [
        _buildIcon(context, Icons.notifications_none),
        if (notificationCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$notificationCount",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 🔹 أيقونات
  Widget _buildIcon(BuildContext context, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (icon == Icons.notifications_none) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const NotificationSheet(),
            );
          } else if (icon == Icons.search) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}