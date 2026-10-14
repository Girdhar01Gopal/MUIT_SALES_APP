import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/repo/lead_repo.dart';
import 'package:muit_sales_app/repo/upload_repo.dart';
import 'package:muit_sales_app/utils/location_helper.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardController extends GetxController {
  final UploadRepo _repo = UploadRepo();
  final LeadRepo _leadRepo = LeadRepo();
  final ImagePicker _picker = ImagePicker();

  // stats
  final RxInt todayVisits = 0.obs;
  final RxInt totalLeads = 0.obs;
  final RxInt statsTick = 0.obs;

  // lead status (live from leads API)
  final RxInt enquiryCount = 0.obs;
  final RxInt followUpCount = 0.obs;
  final RxInt admissionCount = 0.obs;
  final RxBool isLoadingLeads = false.obs;

  // follow-ups due (aaj + pichhle din ke pending), top 10
  final RxList<LeadModel> todayFollowUps = <LeadModel>[].obs;

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
  final RxBool isDownloadingSample = false.obs;

  // sample file kept inside the app (assets/sample/sample_leads.xlsx)
  static const String templateAsset = 'assets/sample/sample_leads.xlsx';
  static const String templateFileName = 'sample_leads.xlsx';

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  // ---------- STATS + REFRESH ----------

  Future<void> loadStats() async {
    try {
      isLoadingLeads.value = true;

      // TODO: yahan Today's Visits ki apni API call lagao, e.g.
      // final stats = await _repo.getDashboardStats();
      // todayVisits.value = stats.todayVisits;
      todayVisits.value = 12; // dummy, API aane pe hata dena

      // leads live fetch -> total, status counts, follow-ups due
      final list = await _leadRepo.getLeads();
      _applyLeads(list);
    } catch (e) {
      Get.snackbar('Error', 'Could not load dashboard data');
    } finally {
      isLoadingLeads.value = false;
      statsTick.value++; // counting 0 se dubara start hogi
    }
  }

  void _applyLeads(List<LeadModel> list) {
    totalLeads.value = list.length;
    enquiryCount.value = list.where((l) => l.status == 'Enquiry').length;
    followUpCount.value = list.where((l) => l.status == 'Follow-up').length;
    admissionCount.value = list.where((l) => l.status == 'Admission').length;

    // follow-up due: aaj ki ya usse pehle ki date, Admission wale nahi
    final today = _todayUtc();
    final due = <MapEntry<DateTime, LeadModel>>[];
    for (final l in list) {
      if (l.status == 'Admission') continue;
      final d = _parseDate(l.followUpDate);
      if (d == null || d.isAfter(today)) continue;
      due.add(MapEntry(d, l));
    }

    // sabse purani (overdue) pehle, phir aaj wali
    due.sort((a, b) => a.key.compareTo(b.key));

    todayFollowUps.assignAll(due.take(10).map((e) => e.value));
  }

  DateTime _todayUtc() {
    final n = DateTime.now();
    return DateTime.utc(n.year, n.month, n.day);
  }

  // follow-up date string (yyyy-MM-dd ya dd-MM-yyyy) -> sirf date (UTC midnight)
  DateTime? _parseDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    DateTime? d = DateTime.tryParse(s);
    if (d != null && d.isUtc) d = d.toLocal();

    if (d == null) {
      final parts = s.split(RegExp(r'[-/.]'));
      if (parts.length == 3) {
        final a = int.tryParse(parts[0]);
        final b = int.tryParse(parts[1]);
        final c = int.tryParse(parts[2]);
        if (a != null && b != null && c != null) {
          d = c > 31 ? DateTime(c, b, a) : DateTime(a, b, c);
        }
      }
    }
    if (d == null) return null;

    return DateTime.utc(d.year, d.month, d.day);
  }

  // kitne din se follow-up pending hai (0 = aaj ki hai)
  int overdueDays(LeadModel lead) {
    final d = _parseDate(lead.followUpDate);
    if (d == null) return 0;
    final diff = _todayUtc().difference(d).inDays;
    return diff > 0 ? diff : 0;
  }

  Future<void> refreshDashboard() async {
    await loadStats();
    // agar photo capture ho chuki hai to location bhi refresh kar do
    if (photo.value != null) {
      await fetchLocation();
    }
  }

  // ---------- NAVIGATION (wapas aane par data refresh) ----------

  Future<void> openRoute(String route, {dynamic arguments}) async {
    await Get.toNamed(route, arguments: arguments);
    await loadStats();
  }

  // Leads screen ko status filter ke saath kholo (Enquiry / Follow-up / Admission)
  Future<void> openLeadsWithStatus(String status) {
    return openRoute(AppRoutes.leads, arguments: {'status': status});
  }

  Future<void> openLead(LeadModel lead) async {
    await Get.toNamed(AppRoutes.crm, arguments: lead);
    await loadStats();
  }

  Future<void> callLead(LeadModel lead) async {
    try {
      final ok = await launchUrl(Uri(scheme: 'tel', path: lead.phone));
      if (!ok) Get.snackbar('Call', 'Could not start the call');
    } catch (e) {
      Get.snackbar('Call', 'Could not start the call');
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

  // STEP 1 : download the sample Excel
  Future<void> downloadSample() async {
    try {
      isDownloadingSample.value = true;

      final data = await rootBundle.load(templateAsset);

      // Android: app's external folder (other apps like Excel can read it)
      // iOS / others: documents folder
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory()) ??
            await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final path = '${dir.path}/$templateFileName';
      await File(path).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );

      final result = await OpenFilex.open(path);
      if (result.type == ResultType.done) {
        Get.snackbar('Sample file', 'Sample Excel downloaded');
      } else {
        Get.snackbar(
          'Sample file',
          'Downloaded, but no app found to open it. Install Excel or Google Sheets.\nSaved at: $path',
        );
      }
    } catch (e, st) {
      debugPrint('SAMPLE DOWNLOAD ERROR: $e');
      debugPrint('$st');
      Get.snackbar('Error', 'Could not download the sample file\n$e');
    } finally {
      isDownloadingSample.value = false;
    }
  }

  // STEP 2 : choose the filled Excel
  Future<void> pickExcel() async {
    final file = await FilePicker.pickFile();
    if (file == null) return;

    const allowed = ['xlsx', 'xls'];

    final ext = file.name.split('.').last.toLowerCase();
    if (!allowed.contains(ext)) {
      Get.snackbar(
        'File',
        'Please select only an Excel file (.xlsx or .xls)',
      );
      return;
    }
    excel.value = file;
  }

  // STEP 3 : upload
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