import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
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

  // Only Excel files allowed
  static const List<String> allowedExt = ['xlsx', 'xls'];

  // Sample file kept inside the app (assets/sample/sample_leads.xlsx)
  static const String templateAsset = 'assets/sample/sample_leads.xlsx';
  static const String templateFileName = 'sample_leads.xlsx';

  final Rx<PlatformFile?> file = Rx<PlatformFile?>(null);
  final RxBool isUploading = false.obs;
  final RxBool isDownloading = false.obs;
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
        name: 'btech_inquiries.xlsx',
        date: '05 Oct 2026',
        size: '82.1 KB',
        status: 'Processed'),
    UploadedFileItem(
        name: 'school_visit_list.xls',
        date: '03 Oct 2026',
        size: '1.2 MB',
        status: 'Pending'),
    UploadedFileItem(
        name: 'mba_leads_sept.xlsx',
        date: '28 Sep 2026',
        size: '410.7 KB',
        status: 'Failed'),
    UploadedFileItem(
        name: 'bca_students_data.xlsx',
        date: '18 Sep 2026',
        size: '530.2 KB',
        status: 'Pending'),
    UploadedFileItem(
        name: 'pharmacy_leads.xlsx',
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

  // Called when a card is tapped -> "Open File"
  void openFile(UploadedFileItem item) {
    if (item.url.isEmpty) {
      Get.snackbar('File', 'File URL not available yet');
      return;
    }
    // TODO (real API): download item.url, then OpenFilex.open(path)
    Get.snackbar('File', 'Opening ${item.name}');
  }

  // ---------- STEP 1 : download the sample Excel ----------
  Future<void> downloadTemplate() async {
    try {
      isDownloading.value = true;

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
    } catch (e) {
      Get.snackbar('Error', 'Could not download the sample file');
    } finally {
      isDownloading.value = false;
    }
  }

  // ---------- STEP 2 : choose the filled Excel ----------
  Future<void> pickFile() async {
    final f = await FilePicker.pickFile();
    if (f == null) return;

    final ext = f.name.split('.').last.toLowerCase();
    if (!allowedExt.contains(ext)) {
      Get.snackbar('File', 'Please select only an Excel file (.xlsx or .xls)');
      return;
    }
    file.value = f;
  }

  // ---------- STEP 3 : upload ----------
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