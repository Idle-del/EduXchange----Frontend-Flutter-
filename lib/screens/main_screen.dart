import 'package:edu_xchange/controller/navigation_controller.dart';
import 'package:edu_xchange/profile/profile_page.dart';
import 'package:edu_xchange/screens/chat_list.dart';
import 'package:edu_xchange/screens/home_screen.dart';
import 'package:edu_xchange/widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The single root screen that hosts the bottom navigation bar and swaps
/// between tabs. This is the widget you should show after login — not
/// HomeScreen directly.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> pages = const [
    HomeScreen(),
    ChatListScreen(),
    SizedBox(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.put(NavigationController());

    return Scaffold(
      // body: Obx(
      //   () => IndexedStack(
      //     index: navigationController.currentIndex.value,
      //     children: pages,
      //   ),
      // ),
      body: Obx(() => pages[navigationController.currentIndex.value]),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}