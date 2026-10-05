import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // lazyPut nahi, put: screen khulte hi controller bane
    Get.put<SplashController>(SplashController());
  }
}