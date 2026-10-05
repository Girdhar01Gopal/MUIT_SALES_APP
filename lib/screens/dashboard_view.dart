import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/wigets/app_drawer.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // light slate gray
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            'assets/images/muit_logo.png',
            height: 34,
            fit: BoxFit.contain,
          ),
        ),
      ),
      drawer: const AppDrawer(),
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

          // ---------- CONTENT (PULL TO REFRESH) ----------
          Positioned.fill(
            child: RefreshIndicator(
              color: AppColors.darkBlue,
              onRefresh: controller.refreshDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            "Today's Visits",
                            controller.todayVisits,
                            Icons.directions_walk,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'Total Leads',
                            controller.totalLeads,
                            Icons.people_alt_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _photoCard(),
                    const SizedBox(height: 16),
                    _excelCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMMON CARD STYLE (white card, black border) ----------
  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.darkBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- STAT CARD ----------
  Widget _statCard(String title, RxInt value, IconData icon) {
    return _glassCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.darkBlue),
          ),
          const SizedBox(height: 10),
          Obx(() => TweenAnimationBuilder<int>(
            key: ValueKey('${controller.statsTick.value}_${value.value}'),
            tween: IntTween(begin: 0, end: value.value),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (context, val, _) => Text(
              '$val',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          )),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------- PHOTO + LOCATION CARD ----------
  Widget _photoCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(Icons.photo_camera_outlined, 'Visit Photo & Location'),
          const SizedBox(height: 14),

          // photo preview
          Obx(() {
            final file = controller.photo.value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                color: const Color(0xFFF1F5F9),
                child: file == null
                    ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 50, color: AppColors.textGrey),
                      SizedBox(height: 8),
                      Text(
                        'No photo captured',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                )
                    : Image.file(file, fit: BoxFit.cover),
              ),
            );
          }),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            style: _outlineStyle(),
            onPressed: controller.capturePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Photo'),
          ),
          const SizedBox(height: 12),

          // location info
          Obx(() {
            if (controller.isLocating.value) {
              return const Row(
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Fetching location...',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ],
              );
            }
            if (controller.address.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _infoRow(Icons.my_location, 'Latitude',
                    controller.lat.value.toStringAsFixed(6)),
                _infoRow(Icons.my_location, 'Longitude',
                    controller.lng.value.toStringAsFixed(6)),
                _infoRow(Icons.location_on, 'Address',
                    controller.address.value),
              ],
            );
          }),
          const SizedBox(height: 12),

          Obx(() => CustomButton(
            label: 'Submit Visit Photo',
            isLoading: controller.isUploadingPhoto.value,
            onPressed: controller.submitPhoto,
          )),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.darkBlue),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- EXCEL CARD ----------
  Widget _excelCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(Icons.table_chart_outlined, 'Excel Upload (Leads)'),
          const SizedBox(height: 14),
          Obx(() => Text(
            controller.excel.value?.name ?? 'No file selected',
            style: const TextStyle(color: AppColors.textGrey),
          )),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: _outlineStyle(),
            onPressed: controller.pickExcel,
            icon: const Icon(Icons.upload_file),
            label: const Text('Choose Excel File'),
          ),
          const SizedBox(height: 12),
          Obx(() => CustomButton(
            label: 'Upload Excel',
            isLoading: controller.isUploadingExcel.value,
            onPressed: controller.uploadExcel,
          )),
        ],
      ),
    );
  }

  ButtonStyle _outlineStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.darkBlue,
      side: const BorderSide(color: AppColors.darkBlue),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}