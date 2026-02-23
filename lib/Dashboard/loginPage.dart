import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../AppTheme/MyColors.dart';
import '../db/database_helper.dart';
import 'HomePage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse("https://api.saisuppliers.com/api/user/login"),
      body: {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      },
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      await DatabaseHelper.instance.insertUser({
        "user_id": data["user"]["user_id"],
        "full_name": data["user"]["full_name"],
        "mobile_number": data["user"]["mobile_number"],
        "email": data["user"]["email"],
        "token": data["token"],
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 30),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                ),
                onPressed: loginUser,
                child: const Text("Login"),
              ),
            )
          ],
        ),
      ),
    );
  }
}