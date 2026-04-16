import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String status;

  const HomeCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
  });

  Color getColor() {
    switch (status) {
      case "طبيعي":
        return AppColors.success;
      case "مرتفع":
        return AppColors.danger;
      case "منخفض":
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(unit, style: TextStyle(color: Colors.grey)),
            ],
          ),

          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: getColor()),
                ),
              ),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
        ],
      ),
    );
  }
}