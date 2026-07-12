import 'package:edu_xchange/controller/navigation_controller.dart';
import 'package:edu_xchange/login/register/login_screen.dart';
import 'package:edu_xchange/utils/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controller/theme_controller.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        // Add other routes here
      ],
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
    );
  }
}

