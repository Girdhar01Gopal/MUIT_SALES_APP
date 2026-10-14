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
      // copy do, taaki screens apni list ko badal sakein
      return List<LeadModel>.from(_leads);
    }

    final res = await _api.get(ApiUrl.leads);
    final List data = res.data['data'];
    return data
        .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------- DUMMY MODE KE LIYE LOCAL SYNC ----------
  // Visit save / CRM edit hone par yahan ki shared list update hoti hai,
  // taaki Dashboard, Leads aur View Visits teeno same data dikhayein.
  // API lagne ke baad (useDummy = false) ye dono kuch nahi karte,
  // backend hi source of truth hoga.

  void addLocal(LeadModel lead) {
    if (!useDummy) return;
    _leads.insert(0, lead);
  }

  void updateLocal(
      int id, {
        String? status,
        String? followUpDate,
        String? priority,
        String? campusVisitDate,
        String? photoPath,
      }) {
    if (!useDummy) return;
    final i = _leads.indexWhere((l) => l.id == id);
    if (i == -1) return;
    _leads[i] = _leads[i].copyWith(
      status: status,
      followUpDate: followUpDate,
      priority: priority,
      campusVisitDate: campusVisitDate,
      photoPath: photoPath,
    );
  }

  // ---------- DUMMY DATA ----------

  // aaj se offset din (0 = aaj, -1 = kal, 3 = 3 din baad) -> 'yyyy-MM-dd'
  // taaki dummy follow-up dates hamesha aaj ke hisaab se rahein
  static String _day(int offset) {
    final t = DateTime.now().add(Duration(days: offset));
    final m = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    return '${t.year}-$m-$d';
  }

  static final List<LeadModel> _leads = _buildDummy();

  static List<LeadModel> _buildDummy() {
    return [
      LeadModel(
        id: 1,
        name: 'Rahul Sharma',
        phone: '9876543210',
        course: 'B.Tech',
        status: 'Enquiry',
        schoolCollege: 'DPS Ghaziabad',
        followUpDate: _day(0),
      ),
      LeadModel(
        id: 2,
        name: 'Priya Singh',
        phone: '9123456780',
        course: 'BBA',
        status: 'Follow-up',
        schoolCollege: 'St. Mary School',
        followUpDate: _day(-4),
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
        followUpDate: _day(3),
      ),
      LeadModel(
        id: 5,
        name: 'Vikas Yadav',
        phone: '9345612780',
        course: 'B.Com',
        status: 'Follow-up',
        schoolCollege: 'Modern Public School',
        followUpDate: _day(-3),
      ),
      LeadModel(
        id: 6,
        name: 'Sneha Tyagi',
        phone: '9871203456',
        course: 'MCA',
        status: 'Admission',
        schoolCollege: 'Amity University',
      ),
      LeadModel(
        id: 7,
        name: 'Karan Mehta',
        phone: '9810012345',
        course: 'B.Tech',
        status: 'Follow-up',
        priority: 'Hot',
        schoolCollege: 'Ryan International',
        followUpDate: _day(0),
      ),
      LeadModel(
        id: 8,
        name: 'Pooja Rani',
        phone: '9899023456',
        course: 'BBA',
        status: 'Enquiry',
        schoolCollege: 'DAV Public School',
        followUpDate: _day(0),
      ),
      LeadModel(
        id: 9,
        name: 'Ankit Chauhan',
        phone: '9911034567',
        course: 'MBA',
        status: 'Follow-up',
        priority: 'Hot',
        schoolCollege: 'IMS College',
        followUpDate: _day(-1),
      ),
      LeadModel(
        id: 10,
        name: 'Ritu Jain',
        phone: '9958045678',
        course: 'BCA',
        status: 'Enquiry',
        priority: 'Cold',
        schoolCollege: 'Modern School',
        followUpDate: _day(0),
      ),
      LeadModel(
        id: 11,
        name: 'Aman Gupta',
        phone: '9654056789',
        course: 'B.Sc',
        status: 'Follow-up',
        schoolCollege: 'KR Mangalam School',
        followUpDate: _day(0),
      ),
      LeadModel(
        id: 12,
        name: 'Shivani Mishra',
        phone: '9717067890',
        course: 'B.Com',
        status: 'Enquiry',
        schoolCollege: 'GD Goenka School',
        followUpDate: _day(-2),
      ),
      LeadModel(
        id: 13,
        name: 'Deepak Kumar',
        phone: '9871078901',
        course: 'B.Tech',
        status: 'Follow-up',
        schoolCollege: 'Kendriya Vidyalaya',
        followUpDate: _day(1),
      ),
      LeadModel(
        id: 14,
        name: 'Anjali Pandey',
        phone: '9582089012',
        course: 'MCA',
        status: 'Admission',
        schoolCollege: 'Lucknow University',
      ),
      LeadModel(
        id: 15,
        name: 'Rohit Saxena',
        phone: '9990090123',
        course: 'BBA',
        status: 'Follow-up',
        priority: 'Cold',
        schoolCollege: 'Amity School',
        followUpDate: _day(-2),
      ),
      LeadModel(
        id: 16,
        name: 'Megha Agarwal',
        phone: '9810101234',
        course: 'B.Tech',
        status: 'Enquiry',
        schoolCollege: 'Delhi Public School',
        followUpDate: _day(2),
      ),
      LeadModel(
        id: 17,
        name: 'Sachin Rana',
        phone: '9818112345',
        course: 'B.Sc',
        status: 'Follow-up',
        schoolCollege: 'Jain College',
        followUpDate: _day(0),
      ),
      LeadModel(
        id: 18,
        name: 'Kajal Sharma',
        phone: '9873123456',
        course: 'BCA',
        status: 'Enquiry',
        schoolCollege: 'Sunbeam School',
        followUpDate: _day(-1),
      ),
      LeadModel(
        id: 19,
        name: 'Mohit Tyagi',
        phone: '9911134567',
        course: 'MBA',
        status: 'Admission',
        schoolCollege: 'IMT Ghaziabad',
      ),
      LeadModel(
        id: 20,
        name: 'Nisha Chauhan',
        phone: '9650145678',
        course: 'B.Com',
        status: 'Follow-up',
        schoolCollege: 'St. Joseph School',
        followUpDate: _day(4),
      ),
    ];
  }
}