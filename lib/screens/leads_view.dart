import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/res/brand.dart';

import '../controllers/leads_controller.dart';

class LeadsView extends GetView<LeadsController> {
  const LeadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.canvas,
      appBar: Brand.appBar('Leads'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.visitEntry),
        backgroundColor: Brand.gold,
        foregroundColor: Brand.ink,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      body: BrandBackground(
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        onChanged: (v) => controller.search.value = v,
        decoration:
            Brand.searchDecoration(hint: 'Search by name, phone or course'),
      ),
    );
  }

  // ---------- FILTER CHIPS ----------
  Widget _filterChips() {
    return SizedBox(
      height: 54,
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
                showCheckmark: false,
                backgroundColor: Colors.white,
                selectedColor: Brand.maroon,
                side: BorderSide(
                  color: selected ? Brand.maroon : Brand.hairlineStrong,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Brand.inkSoft,
                  fontWeight: FontWeight.w700,
                ),
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
        return const Center(
          child: CircularProgressIndicator(color: Brand.maroon),
        );
      }

      final items = controller.filteredLeads;

      return RefreshIndicator(
        color: Brand.maroon,
        onRefresh: controller.fetchLeads,
        child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No leads found',
                      style: TextStyle(color: Brand.inkSoft),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                itemCount: items.length,
                itemBuilder: (_, i) => _leadCard(items[i]),
              ),
      );
    });
  }

  // ---------- LEAD CARD ----------
  Widget _leadCard(LeadModel lead) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.hairline),
        boxShadow: Brand.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => controller.openLead(lead),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Brand.maroon,
                  foregroundColor: Brand.gold,
                  child: Text(
                    lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.w800),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Brand.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lead.course}  •  ${lead.phone}',
                        style: const TextStyle(color: Brand.ink),
                      ),
                      if (lead.schoolCollege.isNotEmpty)
                        Text(
                          lead.schoolCollege,
                          style: const TextStyle(color: Brand.inkSoft),
                        ),
                      if (lead.followUpDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.event,
                                  size: 14, color: Brand.inkSoft),
                              const SizedBox(width: 4),
                              Text(
                                'Follow-up: ${lead.followUpDate}',
                                style: const TextStyle(
                                    fontSize: 12, color: Brand.inkSoft),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    BrandChip(
                      label: lead.status,
                      background: Brand.statusTint(lead.status),
                      foreground: Brand.statusText(lead.status),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      onPressed: () => controller.callLead(lead),
                      style: IconButton.styleFrom(
                        backgroundColor: Brand.maroonTint,
                      ),
                      icon: const Icon(Icons.call, color: Brand.maroon),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
