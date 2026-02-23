import 'dart:async';
import 'package:flutter/material.dart';
import '../AppTheme/MyColors.dart';
import '../db/database_helper.dart';
import 'HomePage.dart';
import 'loginPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    startSplash();
  }

  void startSplash() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = await DatabaseHelper.instance.getUser();

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset(
              "assets/logo.jpeg",
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            const Text(
              "Sai Suppliers",
              style: TextStyle(
                color: MyColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}