import 'package:edu_xchange/controller/navigation_controller.dart';
import 'package:edu_xchange/screens/home_screen.dart';
import 'package:edu_xchange/profile/profile_page.dart';
import 'package:edu_xchange/widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The single root screen that hosts the bottom navigation bar and swaps
/// between tabs. This is the widget you should show after login — not
/// HomeScreen directly.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.put(NavigationController());

    // One instance of each tab. IndexedStack keeps all of them alive in
    // memory (so scroll position, loaded data, etc. survive tab switches)
    // and just changes which one is visible.
    final List<Widget> pages = const [
      HomeScreen(),
      HomeScreen(),
      HomeScreen(),
      ProfilePage(),
      ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navigationController.currentIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}