import 'package:get/get.dart';
import '../controllers/brochure_controller.dart';

class BrochureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrochureController>(() => BrochureController());
  }
}