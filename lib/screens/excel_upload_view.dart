import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';

import '../controllers/excel_upload_controller.dart';

class ExcelUploadView extends GetView<ExcelUploadController> {
  const ExcelUploadView({super.key});

  // Returns the file size (newer file_picker versions have no .size)
  String _sizeText(PlatformFile f) {
    final p = f.path;
    if (p == null) return '';
    try {
      final kb = File(p).lengthSync() / 1024;
      if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(1)} MB';
      return '${kb.toStringAsFixed(1)} KB';
    } catch (_) {
      return '';
    }
  }

  // Icon and color based on file type
  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (ext == 'doc' || ext == 'docx') return Icons.article;
    return Icons.table_chart;
  }

  Color _fileColor(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (ext == 'pdf') return AppColors.error;
    if (ext == 'doc' || ext == 'docx') return const Color(0xFF2563EB);
    return AppColors.success;
  }

  Widget _card({required Widget child}) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // light slate gray
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Excel Upload',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // ---------- WATERMARK ----------
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/muit_spash_logo.webp',
                    width: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // ---------- CONTENT ----------
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // instructions
              _card(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to upload leads',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                        '1. Select an Excel (.xlsx, .xls), .csv, PDF or Word file'),
                    Text('2. For Excel, the first row must contain column names'),
                    Text('3. Tap Upload and your leads will appear in the list'),
                    SizedBox(height: 8),
                    Text(
                      'The required columns depend on the backend (for example Name, Phone, Course).',
                      style:
                      TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // file select + upload
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      final f = controller.file.value;
                      if (f == null) {
                        return const Text(
                          'No file selected',
                          style: TextStyle(color: AppColors.textGrey),
                        );
                      }
                      final size = _sizeText(f);
                      return Row(
                        children: [
                          Icon(_fileIcon(f.name), color: _fileColor(f.name)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              size.isEmpty ? f.name : '${f.name}  ($size)',
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkBlue,
                        side: const BorderSide(color: AppColors.darkBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: controller.pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose File'),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => CustomButton(
                      label: 'Upload',
                      isLoading: controller.isUploading.value,
                      onPressed: controller.upload,
                    )),
                  ],
                ),
              ),

              // last upload
              Obx(() {
                if (controller.lastUploaded.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 18, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Last upload: ${controller.lastUploaded.value}',
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}