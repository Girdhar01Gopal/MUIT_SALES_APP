import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/repo/auth_repo.dart';
import 'package:muit_sales_app/res/app_strings.dart';

class LoginController extends GetxController {
  final AuthRepo _repo = AuthRepo();

  // Jab tak backend API ready nahi, true rakho.
  // API ready hone par false kar dena.
  static const bool useDummyLogin = true;

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscure = true.obs;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      String token;
      if (useDummyLogin) {
        await Future.delayed(const Duration(seconds: 1));
        token = 'dummy_token';
      } else {
        token = await _repo.login(emailCtrl.text.trim(), passCtrl.text);
      }

      GetStorage().write(AppStrings.tokenKey, token);
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar('Error', 'Login fail, Please try again');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}