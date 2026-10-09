import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/fees_model.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/utils/format_helper.dart';
import 'package:muit_sales_app/wigets/app_background.dart';

import '../controllers/fees_controller.dart';

class FeesView extends GetView<FeesController> {
  const FeesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // light slate gray
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Fees',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: AppBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (v) => controller.search.value = v,
                decoration: const InputDecoration(
                  hintText: 'Search course',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.fees.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = controller.filteredFees;

                return RefreshIndicator(
                  onRefresh: controller.fetchFees,
                  child: items.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No courses found')),
                    ],
                  )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
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
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    f.course,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f.duration,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _row('Tuition Fee (per year)', FormatHelper.rupees(f.tuitionFee)),
            _row('Admission Fee (one time)',
                FormatHelper.rupees(f.admissionFee)),
            if (f.hostelFee > 0)
              _row('Hostel (per year, optional)',
                  FormatHelper.rupees(f.hostelFee)),
            const Divider(height: 20),
            _row('First year total', FormatHelper.rupees(f.firstYearTotal),
                bold: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: bold ? AppColors.darkBlue : AppColors.textDark,
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