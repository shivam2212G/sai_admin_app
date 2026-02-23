import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../db/database_helper.dart';
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("https://api.saisuppliers.com/api/user/login"),
        body: {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      ).timeout(const Duration(seconds: 10));

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

        if (!mounted) return;

        // Success animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Login Successful!"),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFF2F7F7B),
            duration: const Duration(seconds: 1),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = const Offset(1.0, 0.0);
                var end = Offset.zero;
                var curve = Curves.easeInOutCubic;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
            ),
          );
        });
      } else {
        _showErrorSnackbar("Login Failed. Please check your credentials.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar("Network error. Please try again.");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 20),

                      // Animated Logo
                      // In the build method of LoginPage, replace the logo Container with this:

                      Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2F4B6E), Color(0xFF2F7F7B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2F4B6E).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  'assets/logo.jpeg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Welcome Text
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F4B6E),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Sign in to continue to Sai Suppliers',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Email Field with animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: "Enter your email",
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: emailController.text.isNotEmpty
                                ? Icon(Icons.check_circle, color: const Color(0xFF2F7F7B))
                                : null,
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password Field with animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 900),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            hintText: "Enter your password",
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Forgot Password with animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Show forgot password dialog
                              _showForgotPasswordDialog();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2F7F7B),
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Login Button with hover effect
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1100),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: isLoading ? null : const LinearGradient(
                              colors: [Color(0xFF2F4B6E), Color(0xFF2F7F7B)],
                            ),
                            boxShadow: isLoading ? null : [
                              BoxShadow(
                                color: const Color(0xFF2F7F7B).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F7F7B).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                              : ElevatedButton(
                            onPressed: loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Footer with animations
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            const Text(
                              'Sai Suppliers',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildAnimatedDot(0),
                                const SizedBox(width: 8),
                                _buildAnimatedDot(1),
                                const SizedBox(width: 8),
                                _buildAnimatedDot(2),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 1500 + index * 200),
      tween: Tween<double>(begin: 0.5, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 30 * value,
          height: 2 * value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: index == 0
                  ? [const Color(0xFF2F4B6E), const Color(0xFF2F7F7B)]
                  : index == 1
                  ? [const Color(0xFF2F7F7B), const Color(0xFF2F7F7B)]
                  : [const Color(0xFF2F7F7B), const Color(0xFF2F4B6E)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Forgot Password?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email_outlined, size: 50, color: Color(0xFF2F7F7B)),
            const SizedBox(height: 20),
            const Text(
              'Enter your email address to reset your password',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Reset link sent to your email'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF2F7F7B),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F7F7B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background effects
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2F7F7B).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      size.width * 0.2,
      paint,
    );

    paint.color = const Color(0xFF2F4B6E).withOpacity(0.03);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.3),
      size.width * 0.25,
      paint,
    );

    paint.color = const Color(0xFF2F7F7B).withOpacity(0.02);
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.8),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}