import 'package:get/get.dart';
import 'package:muit_sales_app/data/api_client.dart';
import 'package:muit_sales_app/data/api_url.dart';

class CrmRepo {
  // Backend ready hone par false kar dena
  static const bool useDummy = true;

  final ApiClient _api = Get.find<ApiClient>();

  Future<bool> updateLead({
    required int id,
    required String status,
    required String followUpDate,
  }) async {
    if (useDummy) {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    }

    final res = await _api.post(
      ApiUrl.updateLead,
      data: {'id': id, 'status': status, 'follow_up_date': followUpDate},
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> addNote({required int leadId, required String note}) async {
    if (useDummy) {
      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    }

    final res = await _api.post(
      ApiUrl.addNote,
      data: {'lead_id': leadId, 'note': note},
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }
}