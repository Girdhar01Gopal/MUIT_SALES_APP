import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/brochure_model.dart';
import 'package:muit_sales_app/res/brand.dart';

import '../controllers/brochure_controller.dart';

class BrochureView extends GetView<BrochureController> {
  const BrochureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.canvas,
      appBar: Brand.appBar('Brochure'),
      body: BrandBackground(
        child: Column(
          children: [
            _searchBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.brochures.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Brand.maroon),
                  );
                }

                final list = controller.filteredBrochures;

                return RefreshIndicator(
                  color: Brand.maroon,
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
                                style: const TextStyle(color: Brand.inkSoft),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Obx(() => TextField(
            controller: controller.searchCtrl,
            onChanged: (v) => controller.searchQuery.value = v,
            textInputAction: TextInputAction.search,
            decoration: Brand.searchDecoration(
              hint: 'Search by title or course...',
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

  Widget _card(BrochureModel b) {
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
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Brand.dangerTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.picture_as_pdf,
                    size: 26, color: Brand.danger),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Brand.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.course,
                      style: const TextStyle(color: Brand.inkSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: Brand.maroonButton(radius: 14, vertical: 13),
                  onPressed: () => controller.open(b),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Open'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: Brand.outlinedButton(),
                  onPressed: () => controller.shareOnWhatsapp(b),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
