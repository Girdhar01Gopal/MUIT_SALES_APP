import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/repo/upload_repo.dart';

class ExcelUploadController extends GetxController {
  final UploadRepo _repo = UploadRepo();

  // Allowed file types
  static const List<String> allowedExt = [
    'xlsx',
    'xls',
    'csv',
    'pdf',
    'doc',
    'docx',
  ];

  final Rx<PlatformFile?> file = Rx<PlatformFile?>(null);
  final RxBool isUploading = false.obs;
  final RxString lastUploaded = ''.obs;

  Future<void> pickFile() async {
    final f = await FilePicker.pickFile();
    if (f == null) return;

    final ext = f.name.split('.').last.toLowerCase();
    if (!allowedExt.contains(ext)) {
      Get.snackbar(
        'File',
        'Please select only .xlsx, .xls, .csv, .pdf, .doc or .docx files',
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