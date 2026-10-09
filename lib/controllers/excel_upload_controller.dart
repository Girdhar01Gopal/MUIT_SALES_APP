import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/repo/upload_repo.dart';

class UploadedFileItem {
  final String name;
  final String date;
  final String size;
  final String status;
  final String url;

  UploadedFileItem({
    required this.name,
    required this.date,
    required this.size,
    required this.status,
    this.url = '',
  });
}

class ExcelUploadController extends GetxController {
  final UploadRepo _repo = UploadRepo();

  // Allowed file types
  static const List<String> allowedExt = [
    'xlsx', 'xls', 'csv',
    'pdf', 'doc', 'docx',
    'jpg', 'jpeg', 'png', 'webp',
  ];

  final Rx<PlatformFile?> file = Rx<PlatformFile?>(null);
  final RxBool isUploading = false.obs;
  final RxString lastUploaded = ''.obs;

  // ---- Uploaded files tab ----
  final RxString searchQuery = ''.obs;

  // Dummy data so the screen is never empty
  final RxList<UploadedFileItem> items = <UploadedFileItem>[
    UploadedFileItem(
        name: 'leads_october.xlsx',
        date: '07 Oct 2026',
        size: '245.3 KB',
        status: 'Processed'),
    UploadedFileItem(
        name: 'btech_inquiries.csv',
        date: '05 Oct 2026',
        size: '82.1 KB',
        status: 'Processed'),
    UploadedFileItem(
        name: 'school_visit_list.xls',
        date: '03 Oct 2026',
        size: '1.2 MB',
        status: 'Pending'),
    UploadedFileItem(
        name: 'fees_brochure.pdf',
        date: '01 Oct 2026',
        size: '3.4 MB',
        status: 'Processed'),
    UploadedFileItem(
        name: 'mba_leads_sept.xlsx',
        date: '28 Sep 2026',
        size: '410.7 KB',
        status: 'Failed'),
    UploadedFileItem(
        name: 'admission_form.docx',
        date: '25 Sep 2026',
        size: '96.0 KB',
        status: 'Processed'),
    UploadedFileItem(
        name: 'campus_visit_photo.jpg',
        date: '22 Sep 2026',
        size: '1.8 MB',
        status: 'Processed'),
    UploadedFileItem(
        name: 'bca_students_data.xlsx',
        date: '18 Sep 2026',
        size: '530.2 KB',
        status: 'Pending'),
    UploadedFileItem(
        name: 'scholarship_details.pdf',
        date: '15 Sep 2026',
        size: '2.1 MB',
        status: 'Processed'),
    UploadedFileItem(
        name: 'pharmacy_leads.csv',
        date: '10 Sep 2026',
        size: '64.8 KB',
        status: 'Failed'),
  ].obs;

  List<UploadedFileItem> get filteredItems {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return items.toList();
    return items.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  // Pull to refresh (replace the delay with your API call later)
  Future<void> refreshList() async {
    await Future.delayed(const Duration(milliseconds: 800));
    items.refresh();
  }

  // Called when a card is tapped
  void openFile(UploadedFileItem item) {
    if (item.url.isEmpty) {
      Get.snackbar('File', 'File URL not available yet');
      return;
    }
    // TODO (real API): image -> preview screen, pdf -> pdf viewer,
    // others -> download + open_filex
    Get.snackbar('File', 'Opening ${item.name}');
  }

  Future<void> pickFile() async {
    final f = await FilePicker.pickFile();
    if (f == null) return;

    final ext = f.name.split('.').last.toLowerCase();
    if (!allowedExt.contains(ext)) {
      Get.snackbar(
        'File',
        'Please select only .xlsx, .xls, .csv, .pdf, .doc, .docx or image files',
      );
      return;
    }
    file.value = f;
  }

  Future<void> upload() async {
    final f = file.value;
    if (f == null) {
      Get.snackbar('File', 'Please select a file first');
      return;
    }
    if (f.path == null) {
      Get.snackbar('File', 'File path not found, please select again');
      return;
    }

    try {
      isUploading.value = true;
      final ok = await _repo.uploadExcel(f);

      if (ok) {
        lastUploaded.value = f.name;

        // show the new upload at the top of the list tab
        final now = DateTime.now();
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        items.insert(
          0,
          UploadedFileItem(
            name: f.name,
            date:
            '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}',
            size: '',
            status: 'Pending',
          ),
        );

        file.value = null;
        Get.snackbar('Success', 'File uploaded successfully');
      } else {
        Get.snackbar('Error', 'Upload failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Upload failed');
    } finally {
      isUploading.value = false;
    }
  }
}