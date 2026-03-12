import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:kivicare_patient/generated/assets.dart';
import '../components/loader_widget.dart';
import '../utils/colors.dart';
import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final SplashScreenController splashController;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    splashController = Get.put(SplashScreenController());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start the animation after a brief delay for smooth status bar integration
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Smooth status bar integration - transparent status bar over gradient
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientEnd],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle radial glow behind logo
            Positioned(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      appColorAccent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Logo with fade-in + scale animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  Assets.assetsAppLogo,
                  height: 160,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            // Loader at bottom with branded teal color
            Positioned(
              bottom: 48,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const LoaderWidget(
                  isBlurBackground: false,
                  loaderColor: appColorAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}