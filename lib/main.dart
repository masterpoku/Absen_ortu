import 'package:absensi_arduino_ortu/firebase_options.dart';
import 'package:absensi_arduino_ortu/page/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/app_asset.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue[800],
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.blue[800],
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.cyan[600],
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.off(const LoginPage());
    });
    return Scaffold(
      backgroundColor: Colors.cyan[600],
      body: Center(
        child: ClipRRect(
          child: Image.asset(
            AppAsset.logo,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
