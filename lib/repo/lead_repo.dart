import 'package:get/get.dart';
import 'package:muit_sales_app/data/api_client.dart';
import 'package:muit_sales_app/data/api_url.dart';
import 'package:muit_sales_app/models/lead_model.dart';

class LeadRepo {
  // Backend ready hone par false kar dena
  static const bool useDummy = true;

  final ApiClient _api = Get.find<ApiClient>();

  Future<List<LeadModel>> getLeads() async {
    if (useDummy) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _dummyLeads;
    }

    final res = await _api.get(ApiUrl.leads);
    final List data = res.data['data'];
    return data
        .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static final List<LeadModel> _dummyLeads = [
    LeadModel(
      id: 1,
      name: 'Rahul Sharma',
      phone: '9876543210',
      course: 'B.Tech',
      status: 'Enquiry',
      schoolCollege: 'DPS Ghaziabad',
      followUpDate: '2026-10-12',
    ),
    LeadModel(
      id: 2,
      name: 'Priya Singh',
      phone: '9123456780',
      course: 'BBA',
      status: 'Follow-up',
      schoolCollege: 'St. Mary School',
      followUpDate: '2026-10-08',
      remarks: 'Fees ke baare me puchha',
    ),
    LeadModel(
      id: 3,
      name: 'Amit Verma',
      phone: '9988776655',
      course: 'MBA',
      status: 'Admission',
      schoolCollege: 'Delhi University',
    ),
    LeadModel(
      id: 4,
      name: 'Neha Gupta',
      phone: '9012345678',
      course: 'BCA',
      status: 'Enquiry',
      schoolCollege: 'KV No. 2',
      followUpDate: '2026-10-15',
    ),
    LeadModel(
      id: 5,
      name: 'Vikas Yadav',
      phone: '9345612780',
      course: 'B.Com',
      status: 'Follow-up',
      schoolCollege: 'Modern Public School',
      followUpDate: '2026-10-09',
    ),
    LeadModel(
      id: 6,
      name: 'Sneha Tyagi',
      phone: '9871203456',
      course: 'MCA',
      status: 'Admission',
      schoolCollege: 'Amity University',
    ),
  ];
}