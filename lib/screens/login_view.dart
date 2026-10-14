import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/res/brand.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';
import 'package:muit_sales_app/wigets/custom_text_field.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: _CrmBackgroundPainter(),
        child: SizedBox.expand(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Guru ji ki image - bina yellow border/padding ke
                      Image.asset(
                        'assets/images/guru ji image .png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to Sales Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        label: 'Email',
                        controller: controller.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter Email'
                            : null,
                      ),
                      Obx(
                            () => CustomTextField(
                          label: 'Password',
                          controller: controller.passCtrl,
                          obscure: controller.obscure.value,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(controller.obscure.value
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => controller.obscure.value =
                            !controller.obscure.value,
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter Password'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                            () => CustomButton(
                          label: 'Login',
                          isLoading: controller.isLoading.value,
                          color: Brand.maroon,
                          onPressed: controller.login,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White background + brown/maroon bands only in top-left & bottom-right corners
class _CrmBackgroundPainter extends CustomPainter {
  static const _brown = Color(0xFFB5714A);
  static const _maroon = Color(0xFF8E1A4A);
  static const _gold = Color(0xFFD4A94A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );

    final maroonPaint = Paint()..color = _maroon;
    final brownPaint = Paint()..color = _brown;
    final goldLine = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // 2. Top-left corner
    final tlMaroon = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.62, 0)
      ..quadraticBezierTo(w * 0.16, h * 0.07, 0, h * 0.24)
      ..close();
    canvas.drawPath(tlMaroon, maroonPaint);

    final tlBrown = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.42, 0)
      ..quadraticBezierTo(w * 0.10, h * 0.05, 0, h * 0.15)
      ..close();
    canvas.drawPath(tlBrown, brownPaint);

    final tlGold = Path()
      ..moveTo(w * 0.72, 0)
      ..quadraticBezierTo(w * 0.22, h * 0.09, 0, h * 0.30);
    canvas.drawPath(tlGold, goldLine);

    // 3. Bottom-right corner
    final brMaroon = Path()
      ..moveTo(w, h)
      ..lineTo(w * 0.38, h)
      ..quadraticBezierTo(w * 0.84, h * 0.93, w, h * 0.76)
      ..close();
    canvas.drawPath(brMaroon, maroonPaint);

    final brBrown = Path()
      ..moveTo(w, h)
      ..lineTo(w * 0.58, h)
      ..quadraticBezierTo(w * 0.90, h * 0.95, w, h * 0.85)
      ..close();
    canvas.drawPath(brBrown, brownPaint);

    final brGold = Path()
      ..moveTo(w * 0.28, h)
      ..quadraticBezierTo(w * 0.78, h * 0.91, w, h * 0.70);
    canvas.drawPath(brGold, goldLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}