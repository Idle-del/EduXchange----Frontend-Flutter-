// ignore_for_file: deprecated_member_use

import 'package:edu_xchange/controller/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState
    extends State<CustomBottomNavigationBar> {

  final NavigationController navigationController =
      Get.find<NavigationController>();
  // Formal, academic-leaning palette, matching the rest of the app.
  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161D2B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: navigationController.currentIndex.value,
            onTap: (index) {
              navigationController.changeIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF161D2B) : Colors.white,
            elevation: 0,
            selectedItemColor: _primaryColor,
            unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[500],
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Browse',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                activeIcon: Icon(Icons.bookmark),
                label: 'Saved',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}