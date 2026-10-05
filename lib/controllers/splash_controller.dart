import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/res/app_strings.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = GetStorage().read(AppStrings.tokenKey);
    if (token != null && token.toString().isNotEmpty) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}