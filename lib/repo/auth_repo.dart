import 'package:get/get.dart';
import 'package:muit_sales_app/data/api_client.dart';
import 'package:muit_sales_app/data/api_url.dart';

class AuthRepo {
  final ApiClient _api = Get.find<ApiClient>();

  /// Token return karta hai.
  /// NOTE: response ka format apne backend ke hisaab se badalna.
  Future<String> login(String email, String password) async {
    final res = await _api.post(
      ApiUrl.login,
      data: {'email': email, 'password': password},
    );
    return res.data['token'].toString();
  }
}