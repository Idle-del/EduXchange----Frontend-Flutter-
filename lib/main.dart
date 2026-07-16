import 'package:edu_xchange/controller/navigation_controller.dart';
import 'package:edu_xchange/login/register/login_screen.dart';
import 'package:edu_xchange/profile/profile_edit.dart';
import 'package:edu_xchange/screens/add_resource.dart';
import 'package:edu_xchange/screens/main_screen.dart';
import 'package:edu_xchange/services/token_service.dart';
import 'package:edu_xchange/utils/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controller/theme_controller.dart';

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();

//   await GetStorage.init();
//   Get.put(ThemeController());
//   Get.put(NavigationController());
//   runApp(const MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isLoggedIn = false;

  final tokenService = TokenService();

  final refreshToken = await tokenService.getRefreshToken();

if (refreshToken != null) {
    isLoggedIn = await tokenService.refreshAccessToken();
}
  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(NavigationController());
  runApp(MyApp(
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:isLoggedIn ? '/main' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/main', page: () => const MainScreen()),
        GetPage(name: '/profile/edit', page: () => const ProfileEdit()),
        GetPage(name: '/add_resource', page: () => const CreateResourceScreen()),
        // Add other routes here
      ],
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
    );
  }
}

