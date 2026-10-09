import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muit_sales_app/repo/upload_repo.dart';
import 'package:muit_sales_app/utils/location_helper.dart';

class DashboardController extends GetxController {
  final UploadRepo _repo = UploadRepo();
  final ImagePicker _picker = ImagePicker();

  // stats
  final RxInt todayVisits = 0.obs;
  final RxInt totalLeads = 0.obs;
  final RxInt statsTick = 0.obs;

  // photo + location
  final Rx<File?> photo = Rx<File?>(null);
  final RxDouble lat = 0.0.obs;
  final RxDouble lng = 0.0.obs;
  final RxString address = ''.obs;
  final RxBool isLocating = false.obs;
  final RxBool isUploadingPhoto = false.obs;

  // excel
  final Rx<PlatformFile?> excel = Rx<PlatformFile?>(null);
  final RxBool isUploadingExcel = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  // ---------- STATS + REFRESH ----------

  Future<void> loadStats() async {
    try {
      // TODO: yahan apni API call lagao, e.g.
      // final stats = await _repo.getDashboardStats();
      // todayVisits.value = stats.todayVisits;
      // totalLeads.value = stats.totalLeads;

      await Future.delayed(const Duration(milliseconds: 600)); // dummy, API aane pe hata dena
      todayVisits.value = 12;
      totalLeads.value = 248;
    } catch (e) {
      Get.snackbar('Error', 'Could not load dashboard data');
    } finally {
      statsTick.value++; // counting 0 se dubara start hogi
    }
  }

  Future<void> refreshDashboard() async {
    await loadStats();
    // agar photo capture ho chuki hai to location bhi refresh kar do
    if (photo.value != null) {
      await fetchLocation();
    }
  }

  // ---------- PHOTO + LOCATION ----------

  Future<void> capturePhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (x == null) return;

    photo.value = File(x.path);
    await fetchLocation(); // photo ke saath location bhi le lo
  }

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

  Future<void> submitPhoto() async {
    if (photo.value == null) {
      Get.snackbar('Photo', 'Please capture a photo first');
      return;
    }
    if (address.value.isEmpty) {
      Get.snackbar('Location', 'Location not found, please try again');
      return;
    }

    try {
      isUploadingPhoto.value = true;
      final ok = await _repo.uploadVisitPhoto(
        photo: photo.value!,
        lat: lat.value,
        lng: lng.value,
        address: address.value,
      );

      if (ok) {
        Get.snackbar('Success', 'Photo uploaded successfully');
        photo.value = null;
        lat.value = 0;
        lng.value = 0;
        address.value = '';
      } else {
        Get.snackbar('Error', 'Upload failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Upload failed');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  // ---------- EXCEL ----------

  Future<void> pickExcel() async {
    final file = await FilePicker.pickFile();
    if (file == null) return;

    const allowed = [
      'xlsx', 'xls', 'csv',
      'pdf', 'doc', 'docx',
      'jpg', 'jpeg', 'png', 'webp',
    ];

    final ext = file.name.split('.').last.toLowerCase();
    if (!allowed.contains(ext)) {
      Get.snackbar(
        'File',
        'Please select .xlsx, .xls, .csv, .pdf, .doc, .docx or image files only',
      );
      return;
    }
    excel.value = file;
  }

  Future<void> uploadExcel() async {
    final file = excel.value;
    if (file == null) {
      Get.snackbar('File', 'Please select a file first');
      return;
    }
    if (file.path == null) {
      Get.snackbar('File', 'File path not found, please select again');
      return;
    }

    try {
      isUploadingExcel.value = true;
      final ok = await _repo.uploadExcel(file);

      if (ok) {
        Get.snackbar('Success', 'File uploaded successfully');
        excel.value = null;
      } else {
        Get.snackbar('Error', 'Upload failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Upload failed');
    } finally {
      isUploadingExcel.value = false;
    }
  }
}