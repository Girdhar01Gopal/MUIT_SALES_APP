import 'package:get/get.dart';
import '../controllers/visit_entry_controller.dart';

class VisitEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisitEntryController>(() => VisitEntryController());
  }
}