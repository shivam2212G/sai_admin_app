import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import 'LoginPage.dart';
import 'HomePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    try {
      final Database db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> users = await db.query('users', limit: 1);

      if (!mounted) return;

      if (users.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              const Color(0xFF2F7F7B).withOpacity(0.15),
              const Color(0xFF2F4B6E).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            ...List.generate(3, (index) {
              return Positioned(
                top: MediaQuery.of(context).size.height * (0.2 + index * 0.1),
                left: MediaQuery.of(context).size.width * (0.1 + index * 0.2),
                child: TweenAnimationBuilder(
                  duration: Duration(milliseconds: 2000 + index * 500),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.5 + value * 0.3,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0
                              ? const Color(0xFF2F7F7B).withOpacity(0.05)
                              : index == 1
                              ? const Color(0xFF2F4B6E).withOpacity(0.05)
                              : const Color(0xFF2F7F7B).withOpacity(0.03),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo with rotation
                  // In the build method of SplashScreen, replace the logo Container with this:

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2F4B6E), Color(0xFF2F7F7B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(45),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2F4B6E).withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Image.asset(
                              'assets/logo.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Text with slide animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF2F4B6E), Color(0xFF2F7F7B)],
                          ).createShader(bounds),
                          child: const Text(
                            'Sai Suppliers',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Your Trusted Partner',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2F4B6E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Loading indicator
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 1500),
                          tween: Tween<double>(begin: 0, end: 1),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    child: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F7F7B)),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}