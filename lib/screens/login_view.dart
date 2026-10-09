import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';
import 'package:muit_sales_app/wigets/custom_text_field.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/muit_logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Email',
                    controller: controller.emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter Email' : null,
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
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter Password' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                        () => CustomButton(
                      label: 'Login',
                      isLoading: controller.isLoading.value,
                      color: const Color(0xFF0284C7),
                      onPressed: controller.login,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}