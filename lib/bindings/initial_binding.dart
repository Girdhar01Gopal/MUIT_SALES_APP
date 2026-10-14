import 'package:get/get.dart';
import 'package:muit_sales_app/data/api_client.dart';
import '../services/log_services.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put<LogService>(LogService(), permanent: true);
  }
}