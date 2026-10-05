import 'package:get/get.dart';
import 'package:muit_sales_app/data/api_client.dart';
import 'package:muit_sales_app/data/api_url.dart';
import 'package:muit_sales_app/models/fees_model.dart';

class FeesRepo {
  // Backend ready hone par false kar dena
  static const bool useDummy = true;

  final ApiClient _api = Get.find<ApiClient>();

  Future<List<FeesModel>> getFees() async {
    if (useDummy) {
      await Future.delayed(const Duration(milliseconds: 700));
      return _dummy;
    }

    final res = await _api.get(ApiUrl.fees);
    final List data = res.data['data'];
    return data
        .map((e) => FeesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Sirf sample numbers hain, asli fees backend se aayengi
  static final List<FeesModel> _dummy = [
    FeesModel(
      course: 'B.Tech',
      duration: '4 Years',
      tuitionFee: 95000,
      admissionFee: 10000,
      hostelFee: 60000,
    ),
    FeesModel(
      course: 'BCA',
      duration: '3 Years',
      tuitionFee: 45000,
      admissionFee: 5000,
      hostelFee: 60000,
    ),
    FeesModel(
      course: 'MBA',
      duration: '2 Years',
      tuitionFee: 110000,
      admissionFee: 10000,
      hostelFee: 60000,
    ),
    FeesModel(
      course: 'MCA',
      duration: '2 Years',
      tuitionFee: 60000,
      admissionFee: 5000,
    ),
    FeesModel(
      course: 'B.Com',
      duration: '3 Years',
      tuitionFee: 30000,
      admissionFee: 5000,
    ),
  ];
}