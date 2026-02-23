import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'splashScreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> logout(BuildContext context) async {
    await DatabaseHelper.instance.deleteUser();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: const Text("Logout"),
        ),
      ),
    );
  }
}