import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/res/brand.dart';
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

  // Only Excel files are used now, so one icon and one color
  IconData _fileIcon(String name) => Icons.table_chart;

  Color _fileColor(String name) => Brand.success;

  Color _statusColor(String status) {
    if (status == 'Processed') return Brand.success;
    if (status == 'Failed') return Brand.danger;
    return Brand.warning;
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.hairline),
        boxShadow: Brand.softShadow,
      ),
      child: child,
    );
  }

  // Bottom sheet shown when a card is tapped
  void _showFileSheet(UploadedFileItem item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Brand.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Date: ${item.date}',
                  style: const TextStyle(color: Brand.ink)),
              const SizedBox(height: 4),
              Text('Size: ${item.size.isEmpty ? '-' : item.size}',
                  style: const TextStyle(color: Brand.ink)),
              const SizedBox(height: 4),
              Text(
                'Status: ${item.status}',
                style: TextStyle(
                  color: _statusColor(item.status),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Open File',
                  isLoading: false,
                  color: Brand.maroon,
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
        backgroundColor: Brand.canvas,
        appBar: Brand.appBar(
          'Excel Upload',
          bottom: const TabBar(
            indicatorColor: Brand.gold,
            indicatorWeight: 3,
            labelColor: Brand.gold,
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

  // ---------------- TAB 1 : download sample -> choose file -> upload ----------------
  Widget _uploadTab() {
    return BrandBackground(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // instructions + sample download
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'How to upload leads',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Brand.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('1. Download the sample Excel file',
                    style: TextStyle(color: Brand.ink)),
                const Text('2. Fill in the leads (do not change the first row)',
                    style: TextStyle(color: Brand.ink)),
                const Text('3. Tap Choose File and select the filled Excel',
                    style: TextStyle(color: Brand.ink)),
                const Text('4. Tap Upload and your leads will appear in the list',
                    style: TextStyle(color: Brand.ink)),
                const SizedBox(height: 8),
                const Text(
                  'Columns: Name, Phone, Email, Course, City. Only .xlsx or .xls files are allowed.',
                  style: TextStyle(color: Brand.inkSoft, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Obx(() => OutlinedButton.icon(
                      style: Brand.outlinedButton(),
                      onPressed: controller.isDownloading.value
                          ? null
                          : controller.downloadTemplate,
                      icon: controller.isDownloading.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Brand.maroon,
                              ),
                            )
                          : const Icon(Icons.download),
                      label: const Text('Download Sample Excel'),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),

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
                      style: TextStyle(color: Brand.inkSoft),
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
                          style: const TextStyle(color: Brand.ink),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: Brand.outlinedButton(),
                  onPressed: controller.pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose File'),
                ),
                const SizedBox(height: 12),
                Obx(() => BrandGoldButton(
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
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 18, color: Brand.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Last upload: ${controller.lastUploaded.value}',
                      style: const TextStyle(color: Brand.success),
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
    return BrandBackground(
      child: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: Brand.searchDecoration(hint: 'Search files...'),
            ),
          ),

          // list with pull to refresh
          Expanded(
            child: RefreshIndicator(
              color: Brand.maroon,
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
                          style: TextStyle(color: Brand.inkSoft),
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
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showFileSheet(item),
                      child: _card(
                        child: Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: Brand.successTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_fileIcon(item.name),
                                  color: _fileColor(item.name), size: 26),
                            ),
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
                                      fontWeight: FontWeight.w800,
                                      color: Brand.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sub,
                                    style: const TextStyle(
                                        color: Brand.inkSoft, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.status,
                              style: TextStyle(
                                color: _statusColor(item.status),
                                fontWeight: FontWeight.w700,
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
