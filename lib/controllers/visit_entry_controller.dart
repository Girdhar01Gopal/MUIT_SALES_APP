import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/models/visit_model.dart';
import 'package:muit_sales_app/repo/lead_repo.dart';
import 'package:muit_sales_app/repo/visit_repo.dart';
import 'package:muit_sales_app/utils/location_helper.dart';

class VisitEntryController extends GetxController {
  final VisitRepo _repo = VisitRepo();
  final LeadRepo _leadRepo = LeadRepo();

  // form
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final schoolCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final followUpCtrl = TextEditingController();

  // dropdown options (change as per your university)
  final List<String> courses = [
    'B.Tech', 'BCA', 'MCA', 'BBA', 'MBA', 'B.Com', 'B.Sc', 'Other',
  ];
  final List<String> statuses = ['Enquiry', 'Admission', 'Follow-up'];

  final Rxn<String> course = Rxn<String>();
  final RxString status = 'Enquiry'.obs;

  // location
  final RxDouble lat = 0.0.obs;
  final RxDouble lng = 0.0.obs;
  final RxString address = ''.obs;
  final RxBool isLocating = false.obs;

  final RxBool isSaving = false.obs;

  // view visits tab
  final RxList<LeadModel> visits = <LeadModel>[].obs;
  final RxBool isLoadingVisits = false.obs;

  // search
  final searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLocation(); // get the location as soon as the screen opens
    fetchVisits();
  }



  // ---------- SEARCH ----------

  List<LeadModel> get filteredVisits {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return visits;

    return visits.where((v) {
      return v.name.toLowerCase().contains(q) ||
          v.course.toLowerCase().contains(q) ||
          v.phone.toLowerCase().contains(q) ||
          v.schoolCollege.toLowerCase().contains(q) ||
          v.status.toLowerCase().contains(q) ||
          v.followUpDate.toLowerCase().contains(q) ||
          v.remarks.toLowerCase().contains(q);
    }).toList();
  }

  void clearSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
  }
  // ---------- VIEW VISITS ----------

  Future<void> fetchVisits() async {
    try {
      isLoadingVisits.value = true;
      visits.value = await _leadRepo.getLeads();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load visits');
    } finally {
      isLoadingVisits.value = false;
    }
  }



  // ---------- LOCATION ----------

  Future<void> fetchLocation() async {
    isLocating.value = true;
    final loc = await LocationHelper.getCurrent();
    isLocating.value = false;

    if (loc == null) {
      Get.snackbar(
        'Location',
        'Location not found. Please turn on GPS and allow permission.',
      );
      return;
    }

    lat.value = loc.lat;
    lng.value = loc.lng;
    address.value = loc.address;
  }

  Future<void> pickFollowUpDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: Get.context!,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d == null) return;
    followUpCtrl.text = '${d.year}-${_two(d.month)}-${_two(d.day)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  // ---------- SAVE ----------

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    if (address.value.isEmpty) {
      Get.snackbar('Location', 'Location not found, please tap refresh');
      return;
    }

    try {
      isSaving.value = true;

      final visit = VisitModel(
        studentName: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        schoolCollege: schoolCtrl.text.trim(),
        course: course.value ?? '',
        status: status.value,
        remarks: remarksCtrl.text.trim(),
        followUpDate: followUpCtrl.text.trim(),
        lat: lat.value,
        lng: lng.value,
        address: address.value,
      );

      final ok = await _repo.addVisit(visit);

      if (ok) {
        Get.back(); // close the screen first, then show the snackbar
        Get.snackbar('Success', 'Visit saved');
      } else {
        Get.snackbar('Error', 'Could not save the visit');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save the visit');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    schoolCtrl.dispose();
    remarksCtrl.dispose();
    followUpCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}