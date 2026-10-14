import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/fees_model.dart';
import 'package:muit_sales_app/res/brand.dart';
import 'package:muit_sales_app/utils/format_helper.dart';

import '../controllers/fees_controller.dart';

class FeesView extends GetView<FeesController> {
  const FeesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.canvas,
      appBar: Brand.appBar('CRM Fees'),
      body: BrandBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: TextField(
                onChanged: (v) => controller.search.value = v,
                decoration: Brand.searchDecoration(hint: 'Search course'),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.fees.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Brand.maroon),
                  );
                }

                final items = controller.filteredFees;

                return RefreshIndicator(
                  color: Brand.maroon,
                  onRefresh: controller.fetchFees,
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'No courses found',
                                style: TextStyle(color: Brand.inkSoft),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _card(items[i]),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(FeesModel f) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.hairline),
        boxShadow: Brand.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  f.course,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Brand.ink,
                  ),
                ),
              ),
              BrandChip(
                label: f.duration,
                background: Brand.goldChip,
                foreground: Brand.goldText,
              ),
            ],
          ),
          const Divider(height: 22, color: Brand.hairline),
          _row('Tuition Fee (per year)', FormatHelper.rupees(f.tuitionFee)),
          _row('Admission Fee (one time)',
              FormatHelper.rupees(f.admissionFee)),
          if (f.hostelFee > 0)
            _row('Hostel (per year, optional)',
                FormatHelper.rupees(f.hostelFee)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Brand.goldTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Brand.goldTintBorder),
            ),
            child: _row(
              'First year total',
              FormatHelper.rupees(f.firstYearTotal),
              bold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 15 : 14,
      color: bold ? Brand.maroon : Brand.ink,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
