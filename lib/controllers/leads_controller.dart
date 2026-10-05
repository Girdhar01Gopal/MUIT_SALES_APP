import 'package:get/get.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/repo/lead_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadsController extends GetxController {
  final LeadRepo _repo = LeadRepo();

  final RxList<LeadModel> leads = <LeadModel>[].obs;
  final RxBool isLoading = false.obs;

  final RxString search = ''.obs;
  final RxString selectedStatus = 'All'.obs;

  final List<String> filters = ['All', 'Enquiry', 'Follow-up', 'Admission'];

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
  }

  Future<void> fetchLeads() async {
    try {
      isLoading.value = true;
      leads.value = await _repo.getLeads();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load leads');
    } finally {
      isLoading.value = false;
    }
  }

  // Returns the list with both search and status filter applied
  List<LeadModel> get filteredLeads {
    final q = search.value.toLowerCase().trim();

    return leads.where((l) {
      final okStatus =
          selectedStatus.value == 'All' || l.status == selectedStatus.value;
      final okSearch = q.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.phone.contains(q) ||
          l.course.toLowerCase().contains(q);
      return okStatus && okSearch;
    }).toList();
  }

  // Used to show the count next to each chip
  int countFor(String status) {
    if (status == 'All') return leads.length;
    return leads.where((l) => l.status == status).length;
  }

  Future<void> callLead(LeadModel lead) async {
    try {
      final ok = await launchUrl(Uri(scheme: 'tel', path: lead.phone));
      if (!ok) Get.snackbar('Call', 'Could not start the call');
    } catch (e) {
      Get.snackbar('Call', 'Could not start the call');
    }
  }

  // Open the CRM detail screen and pass the lead as arguments
  void openLead(LeadModel lead) {
    Get.toNamed(AppRoutes.crm, arguments: lead);
  }

  // When status/date changes on the CRM screen, update the list immediately
  void updateLocal(int id, String status, String followUpDate) {
    final i = leads.indexWhere((l) => l.id == id);
    if (i == -1) return;
    leads[i] = leads[i].copyWith(status: status, followUpDate: followUpDate);
  }
}