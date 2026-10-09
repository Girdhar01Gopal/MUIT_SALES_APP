import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/wigets/app_background.dart';

import '../controllers/leads_controller.dart';

class LeadsView extends GetView<LeadsController> {
  const LeadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // light slate gray
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Leads',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.visitEntry),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: AppBackground(
        child: Column(
          children: [
            _searchBox(),
            _filterChips(),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
  }

  // ---------- SEARCH ----------
  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (v) => controller.search.value = v,
        decoration: const InputDecoration(
          hintText: 'Search by name, phone or course',
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // ---------- FILTER CHIPS ----------
  Widget _filterChips() {
    return SizedBox(
      height: 52,
      child: Obx(
            () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: controller.filters.map((f) {
            final selected = controller.selectedStatus.value == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$f (${controller.countFor(f)})'),
                selected: selected,
                backgroundColor: Colors.white,
                onSelected: (_) => controller.selectedStatus.value = f,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------- LIST ----------
  Widget _list() {
    return Obx(() {
      if (controller.isLoading.value && controller.leads.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = controller.filteredLeads;

      return RefreshIndicator(
        onRefresh: controller.fetchLeads,
        child: items.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No leads found')),
          ],
        )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
          itemCount: items.length,
          itemBuilder: (_, i) => _leadCard(items[i]),
        ),
      );
    });
  }

  // ---------- LEAD CARD ----------
  Widget _leadCard(LeadModel lead) {
    final color = _statusColor(lead.status);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.openLead(lead),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                child: Text(
                  lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text('${lead.course}  •  ${lead.phone}'),
                    if (lead.schoolCollege.isNotEmpty)
                      Text(
                        lead.schoolCollege,
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                    if (lead.followUpDate.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.event,
                                size: 14, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(
                              'Follow-up: ${lead.followUpDate}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lead.status,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.callLead(lead),
                    icon: const Icon(Icons.call, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
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