import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/wigets/app_background.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';
import 'package:muit_sales_app/wigets/custom_dropdown.dart';
import 'package:muit_sales_app/wigets/custom_text_field.dart';

import '../controllers/visit_entry_controller.dart';

class VisitEntryView extends GetView<VisitEntryController> {
  const VisitEntryView({super.key});

  // White card with black border (same as other screens)
  static final RoundedRectangleBorder _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: Colors.black, width: 1),
  );

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
            'Visit Entry',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Add Visit'),
              Tab(icon: Icon(Icons.list_alt), text: 'View Visits'),
            ],
          ),
        ),
        body: AppBackground(
          child: TabBarView(
            children: [
              _addTab(),
              _viewTab(),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // TAB 1 : ADD VISIT
  // =====================================================
  Widget _addTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Student Name',
              controller: controller.nameCtrl,
              prefixIcon: Icons.person_outline,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter name' : null,
            ),
            CustomTextField(
              label: 'Phone Number',
              controller: controller.phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter phone number';
                if (!RegExp(r'^[0-9]{10}$').hasMatch(v.trim())) {
                  return 'Enter a 10-digit number';
                }
                return null;
              },
            ),
            CustomTextField(
              label: 'School / College',
              controller: controller.schoolCtrl,
              prefixIcon: Icons.school_outlined,
            ),
            Obx(() => CustomDropdown(
              label: 'Course Interest',
              items: controller.courses,
              value: controller.course.value,
              prefixIcon: Icons.menu_book_outlined,
              onChanged: (v) => controller.course.value = v,
              validator: (v) => v == null ? 'Select a course' : null,
            )),
            Obx(() => CustomDropdown(
              label: 'Status',
              items: controller.statuses,
              value: controller.status.value,
              prefixIcon: Icons.flag_outlined,
              onChanged: (v) {
                if (v != null) controller.status.value = v;
              },
            )),
            CustomTextField(
              label: 'Next Follow-up Date',
              controller: controller.followUpCtrl,
              readOnly: true,
              prefixIcon: Icons.event,
              suffixIcon: const Icon(Icons.calendar_month),
              onTap: controller.pickFollowUpDate,
            ),
            CustomTextField(
              label: 'Remarks',
              controller: controller.remarksCtrl,
              maxLines: 3,
              prefixIcon: Icons.notes,
            ),
            const SizedBox(height: 8),
            _locationCard(),
            const SizedBox(height: 16),
            Obx(() => CustomButton(
              label: 'Save Visit',
              isLoading: controller.isSaving.value,
              onPressed: controller.save,
            )),
          ],
        ),
      ),
    );
  }

  // ---------- LOCATION CARD ----------
  Widget _locationCard() {
    return Card(
      color: Colors.white,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Visit Location',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: controller.fetchLocation,
                  icon: const Icon(Icons.refresh, color: AppColors.darkBlue),
                  tooltip: 'Refresh location',
                ),
              ],
            ),
            Obx(() {
              if (controller.isLocating.value) {
                return const Row(
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Fetching location...'),
                  ],
                );
              }
              if (controller.address.value.isEmpty) {
                return const Text(
                  'Location not found yet',
                  style: TextStyle(color: AppColors.textGrey),
                );
              }
              return Column(
                children: [
                  _infoRow(Icons.my_location, 'Latitude',
                      controller.lat.value.toStringAsFixed(6)),
                  _infoRow(Icons.my_location, 'Longitude',
                      controller.lng.value.toStringAsFixed(6)),
                  _infoRow(
                      Icons.location_on, 'Address', controller.address.value),
                ],
              );
            }),
          ],
        ),
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
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // =====================================================
  // TAB 2 : VIEW VISITS
  // =====================================================
  // =====================================================
  // TAB 2 : VIEW VISITS
  // =====================================================
  Widget _viewTab() {
    return Column(
      children: [
        _searchBar(),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingVisits.value &&
                controller.visits.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = controller.filteredVisits;

            return RefreshIndicator(
              onRefresh: controller.fetchVisits,
              child: list.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      controller.searchQuery.value.isEmpty
                          ? 'No visits found'
                          : 'No matching visits',
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (_, i) => _visitCard(list[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------- SEARCH BAR ----------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Obx(() => TextField(
        controller: controller.searchCtrl,
        onChanged: (v) => controller.searchQuery.value = v,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by name, course, phone, status...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.searchQuery.value.isEmpty
              ? null
              : IconButton(
            icon: const Icon(Icons.close),
            onPressed: controller.clearSearch,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
            const BorderSide(color: AppColors.darkBlue, width: 1.5),
          ),
        ),
      )),
    );
  }

  Widget _visitCard(LeadModel v) {
    final color = _statusColor(v.status);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              child: Text(
                v.name.isNotEmpty ? v.name[0].toUpperCase() : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text('${v.course}  •  ${v.phone}'),
                  if (v.schoolCollege.isNotEmpty)
                    Text(
                      v.schoolCollege,
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  if (v.followUpDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.event,
                              size: 14, color: AppColors.textGrey),
                          const SizedBox(width: 4),
                          Text(
                            'Follow-up: ${v.followUpDate}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  if (v.remarks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        v.remarks,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                v.status,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Admission':
        return AppColors.success;
      case 'Follow-up':
        return AppColors.secondary;
      default:
        return AppColors.darkBlue; // Enquiry
    }
  }
}