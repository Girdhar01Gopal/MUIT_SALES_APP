import 'package:get/get.dart';
import 'package:muit_sales_app/data/api_client.dart';
import 'package:muit_sales_app/data/api_url.dart';
import 'package:muit_sales_app/models/brochure_model.dart';

class BrochureRepo {
  // Backend ready hone par false kar dena
  static const bool useDummy = true;

  final ApiClient _api = Get.find<ApiClient>();

  Future<List<BrochureModel>> getBrochures() async {
    if (useDummy) {
      await Future.delayed(const Duration(milliseconds: 700));
      return _dummy;
    }

    final res = await _api.get(ApiUrl.brochure);
    final List data = res.data['data'];
    return data
        .map((e) => BrochureModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Sample data: asli PDF links backend se aayenge
  static final List<BrochureModel> _dummy = [
    BrochureModel(
      id: 1,
      title: 'University Prospectus 2026-27',
      course: 'All Courses',
      url: 'https://example.com/brochures/prospectus.pdf',
    ),
    BrochureModel(
      id: 2,
      title: 'B.Tech Brochure',
      course: 'B.Tech',
      url: 'https://example.com/brochures/btech.pdf',
    ),
    BrochureModel(
      id: 3,
      title: 'MBA Brochure',
      course: 'MBA',
      url: 'https://example.com/brochures/mba.pdf',
    ),
    BrochureModel(
      id: 4,
      title: 'BCA / MCA Brochure',
      course: 'BCA, MCA',
      url: 'https://example.com/brochures/bca_mca.pdf',
    ),
  ];
}