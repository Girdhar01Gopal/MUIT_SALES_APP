import 'package:get/get.dart';
import '../controllers/excel_upload_controller.dart';

class ExcelUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExcelUploadController>(() => ExcelUploadController());
  }
}