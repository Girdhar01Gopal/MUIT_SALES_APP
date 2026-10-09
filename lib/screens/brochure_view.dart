import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/brochure_model.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/wigets/app_background.dart';

import '../controllers/brochure_controller.dart';

class BrochureView extends GetView<BrochureController> {
  const BrochureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // light slate gray
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Brochure',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: AppBackground(
        child: Column(
          children: [
            _searchBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.brochures.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.filteredBrochures;

                return RefreshIndicator(
                  onRefresh: controller.fetchBrochures,
                  child: list.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          controller.searchQuery.value.isEmpty
                              ? 'No brochures found'
                              : 'No matching brochures',
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _card(list[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
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
          hintText: 'Search by title or course...',
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

  Widget _card(BrochureModel b) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf,
                    size: 36, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        b.course,
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.open(b),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.shareOnWhatsapp(b),
                    icon: const Icon(Icons.share),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}