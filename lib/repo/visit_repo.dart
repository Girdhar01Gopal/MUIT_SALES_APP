import 'package:get/get.dart';
import 'package:muit_sales_app/data/api_client.dart';
import 'package:muit_sales_app/data/api_url.dart';
import 'package:muit_sales_app/models/visit_model.dart';

class VisitRepo {
  // Backend ready hone par false kar dena
  static const bool useDummy = true;

  final ApiClient _api = Get.find<ApiClient>();

  Future<bool> addVisit(VisitModel visit) async {
    if (useDummy) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    final res = await _api.post(ApiUrl.addVisit, data: visit.toJson());
    return res.statusCode == 200 || res.statusCode == 201;
  }
}