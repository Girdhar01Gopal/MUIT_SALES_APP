import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/wigets/app_background.dart';
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
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp') {
      return Icons.image;
    }
    return Icons.table_chart;
  }

  Color _fileColor(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (ext == 'pdf') return AppColors.error;
    if (ext == 'doc' || ext == 'docx') return const Color(0xFF2563EB);
    return AppColors.success;
  }

  Color _statusColor(String status) {
    if (status == 'Processed') return AppColors.success;
    if (status == 'Failed') return AppColors.error;
    return Colors.orange;
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

  // Bottom sheet shown when a card is tapped
  void _showFileSheet(UploadedFileItem item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_fileIcon(item.name),
                      color: _fileColor(item.name), size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Date: ${item.date}'),
              const SizedBox(height: 4),
              Text('Size: ${item.size.isEmpty ? '-' : item.size}'),
              const SizedBox(height: 4),
              Text(
                'Status: ${item.status}',
                style: TextStyle(color: _statusColor(item.status)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Open File',
                  isLoading: false,
                  onPressed: () {
                    Get.back();
                    controller.openFile(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFE2E8F0), // light slate gray
        appBar: AppBar(
          backgroundColor: AppColors.darkBlueDeep,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Excel Upload',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.upload_file), text: 'Upload'),
              Tab(icon: Icon(Icons.list_alt), text: 'Uploaded Files'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _uploadTab(),
            _listTab(),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 1 : existing upload screen ----------------
  Widget _uploadTab() {
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // instructions
          _card(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to upload leads',
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                    '1. Select an Excel (.xlsx, .xls), .csv, PDF or Word file'),
                Text('2. For Excel, the first row must contain column names'),
                Text('3. Tap Upload and your leads will appear in the list'),
                SizedBox(height: 8),
                Text(
                  'The required columns depend on the backend (for example Name, Phone, Course).',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
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
    );
  }

  // ---------------- TAB 2 : search + pull to refresh + list ----------------
  Widget _listTab() {
    return AppBackground(
      child: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search files...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: AppColors.darkBlue, width: 1.5),
                ),
              ),
            ),
          ),

          // list with pull to refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshList,
              child: Obx(() {
                final list = controller.filteredItems;

                if (list.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No files found',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final sub = item.size.isEmpty
                        ? item.date
                        : '${item.date}  •  ${item.size}';
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showFileSheet(item),
                      child: _card(
                        child: Row(
                          children: [
                            Icon(_fileIcon(item.name),
                                color: _fileColor(item.name), size: 30),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sub,
                                    style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.status,
                              style: TextStyle(
                                color: _statusColor(item.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}