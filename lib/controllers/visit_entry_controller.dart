import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/models/visit_model.dart';
import 'package:muit_sales_app/repo/lead_repo.dart';
import 'package:muit_sales_app/repo/visit_repo.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/utils/location_helper.dart';

class VisitEntryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final VisitRepo _repo = VisitRepo();
  final LeadRepo _leadRepo = LeadRepo();

  // Tab controller for programmatically switching between Add Visit and View Visits
  late TabController tabController;

  // Form
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final schoolCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final followUpCtrl = TextEditingController();

  // Dropdown options
  final List<String> courses = [
    'B.Tech',
    'BCA',
    'MCA',
    'BBA',
    'MBA',
    'B.Com',
    'B.Sc',
    'Other',
  ];
  final List<String> statuses = ['Enquiry', 'Admission', 'Follow-up'];

  final Rxn<String> course = Rxn<String>();
  final RxString status = 'Enquiry'.obs;

  // Location
  final RxDouble lat = 0.0.obs;
  final RxDouble lng = 0.0.obs;
  final RxString address = ''.obs;
  final RxBool isLocating = false.obs;

  final RxBool isSaving = false.obs;

  // View visits tab
  final RxList<LeadModel> visits = <LeadModel>[].obs;
  final RxBool isLoadingVisits = false.obs;

  // Search
  final searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchLocation();
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

  // ---------- SAVE VISIT & OPTION 2 DIALOG FLOW ----------

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
        // Show Option 2 Dialog popup asking for photo capture
        _showCapturePhotoDialog(visit);
      } else {
        Get.snackbar('Error', 'Could not save the visit');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save the visit');
    } finally {
      isSaving.value = false;
    }
  }

  void _showCapturePhotoDialog(VisitModel visit) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.darkBlue,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Visit Saved Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Do you want to capture & upload a visit photo now?',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        _finishAndNavigateToVisits(visit: visit, photoPath: null);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkBlue,
                        side: const BorderSide(color: AppColors.darkBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Later / Skip'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Get.back(); // Close dialog
                        await _capturePhotoAndFinish(visit);
                      },
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Capture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _capturePhotoAndFinish(VisitModel visit) async {
    try {
      final picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      String? photoPath;
      if (xFile != null) {
        photoPath = xFile.path;
      }

      _finishAndNavigateToVisits(visit: visit, photoPath: photoPath);
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture photo');
      _finishAndNavigateToVisits(visit: visit, photoPath: null);
    }
  }

  void _finishAndNavigateToVisits({
    required VisitModel visit,
    required String? photoPath,
  }) {
    // Add newly created visit to 'visits' list so it displays at the top in View Visits tab
    final newLead = LeadModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: visit.studentName,
      phone: visit.phone,
      course: visit.course,
      status: visit.status,
      schoolCollege: visit.schoolCollege,
      followUpDate: visit.followUpDate,
      remarks: visit.remarks,
      address: visit.address,
      lat: visit.lat,
      lng: visit.lng,
      photoPath: photoPath,
    );

    // shared repo list me bhi daalo, taaki Dashboard / Leads me turant dikhe
    _leadRepo.addLocal(newLead);

    visits.insert(0, newLead);

    // Reset Form
    clearForm();

    // Show Notification
    if (photoPath != null) {
      Get.snackbar('Success', 'Visit saved & photo captured successfully!');
    } else {
      Get.snackbar('Success', 'Visit saved successfully!');
    }

    // Switch tab to View Visits (Tab Index 1)
    tabController.animateTo(1);
  }

  // Allow capturing photo for an existing visit card in View Visits tab
  Future<void> capturePhotoForVisit(LeadModel lead) async {
    try {
      final picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (xFile == null) return;

      final index = visits.indexWhere((v) => v.id == lead.id);
      if (index != -1) {
        visits[index] = visits[index].copyWith(photoPath: xFile.path);
        visits.refresh();
        _leadRepo.updateLocal(lead.id, photoPath: xFile.path);
        Get.snackbar('Success', 'Photo attached to ${lead.name}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not attach photo');
    }
  }

  void clearForm() {
    nameCtrl.clear();
    phoneCtrl.clear();
    schoolCtrl.clear();
    remarksCtrl.clear();
    followUpCtrl.clear();
    course.value = null;
    status.value = 'Enquiry';
    fetchLocation();
  }

  @override
  void onClose() {
    tabController.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    schoolCtrl.dispose();
    remarksCtrl.dispose();
    followUpCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}