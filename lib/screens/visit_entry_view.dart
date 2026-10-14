import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/res/brand.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';
import 'package:muit_sales_app/wigets/custom_dropdown.dart';
import 'package:muit_sales_app/wigets/custom_text_field.dart';

import '../controllers/visit_entry_controller.dart';

class VisitEntryView extends GetView<VisitEntryController> {
  const VisitEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.canvas,
      appBar: Brand.appBar(
        'Visit Entry',
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: Brand.gold,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Brand.gold,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Add Visit'),
            Tab(icon: Icon(Icons.list_alt), text: 'View Visits'),
          ],
        ),
      ),
      body: BrandBackground(
        child: TabBarView(
          controller: controller.tabController,
          children: [
            _addTab(),
            _viewTab(),
          ],
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
              prefixText: '+91 ',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
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
                  color: Brand.maroon,
                  onPressed: controller.save,
                )),
          ],
        ),
      ),
    );
  }

  // ---------- LOCATION CARD ----------
  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.hairline),
        boxShadow: Brand.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Visit Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Brand.ink,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.fetchLocation,
                style: IconButton.styleFrom(backgroundColor: Brand.maroonTint),
                icon: const Icon(Icons.refresh, color: Brand.maroon),
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Brand.maroon,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Fetching location...',
                      style: TextStyle(color: Brand.ink)),
                ],
              );
            }
            if (controller.address.value.isEmpty) {
              return const Text(
                'Location not found yet',
                style: TextStyle(color: Brand.inkSoft),
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
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Brand.maroon),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Brand.ink)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Brand.ink)),
          ),
        ],
      ),
    );
  }

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
              return const Center(
                child: CircularProgressIndicator(color: Brand.maroon),
              );
            }

            final list = controller.filteredVisits;

            return RefreshIndicator(
              color: Brand.maroon,
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
                            style: const TextStyle(color: Brand.inkSoft),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Obx(() => TextField(
            controller: controller.searchCtrl,
            onChanged: (v) => controller.searchQuery.value = v,
            textInputAction: TextInputAction.search,
            decoration: Brand.searchDecoration(
              hint: 'Search by name, course, phone, status...',
              suffixIcon: controller.searchQuery.value.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, color: Brand.inkSoft),
                      onPressed: controller.clearSearch,
                    ),
            ),
          )),
    );
  }

  // ---------- VISIT CARD WITH CAPTURED IMAGE ----------
  Widget _visitCard(LeadModel v) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.hairline),
        boxShadow: Brand.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Brand.maroon,
                foregroundColor: Brand.gold,
                child: Text(
                  v.name.isNotEmpty ? v.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.w800),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Brand.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('${v.course}  •  ${v.phone}',
                        style: const TextStyle(color: Brand.ink)),
                    if (v.schoolCollege.isNotEmpty)
                      Text(
                        v.schoolCollege,
                        style: const TextStyle(color: Brand.inkSoft),
                      ),
                    if (v.followUpDate.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.event,
                                size: 14, color: Brand.inkSoft),
                            const SizedBox(width: 4),
                            Text(
                              'Follow-up: ${v.followUpDate}',
                              style: const TextStyle(
                                  fontSize: 12, color: Brand.inkSoft),
                            ),
                          ],
                        ),
                      ),
                    if (v.address != null && v.address!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Brand.maroon),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                v.address!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Brand.inkSoft),
                              ),
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
                              fontSize: 12, color: Brand.inkSoft),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BrandChip(
                label: v.status,
                background: Brand.statusTint(v.status),
                foreground: Brand.statusText(v.status),
              ),
            ],
          ),

          // Captured Visit Photo Display
          if (v.photoPath != null && v.photoPath!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 160,
                width: double.infinity,
                color: Brand.blush,
                child: _buildVisitImage(v.photoPath!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisitImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Brand.inkSoft),
        ),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_outlined, color: Brand.inkSoft, size: 30),
          SizedBox(height: 4),
          Text('Photo attached',
              style: TextStyle(color: Brand.inkSoft, fontSize: 12)),
        ],
      ),
    );
  }
}
