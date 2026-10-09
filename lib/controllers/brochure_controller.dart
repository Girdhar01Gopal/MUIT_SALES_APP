import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/brochure_model.dart';
import 'package:muit_sales_app/repo/brochure_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class BrochureController extends GetxController {
  final BrochureRepo _repo = BrochureRepo();

  final RxList<BrochureModel> brochures = <BrochureModel>[].obs;
  final RxBool isLoading = false.obs;

  // search
  final searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBrochures();
  }

  // ---------- SEARCH ----------

  List<BrochureModel> get filteredBrochures {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return brochures;

    return brochures.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.course.toLowerCase().contains(q);
    }).toList();
  }

  void clearSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
  }

  Future<void> fetchBrochures() async {
    try {
      isLoading.value = true;
      brochures.value = await _repo.getBrochures();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load brochures');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> open(BrochureModel b) async {
    try {
      final ok = await launchUrl(
        Uri.parse(b.url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) Get.snackbar('Brochure', 'Could not open the link');
    } catch (e) {
      Get.snackbar('Brochure', 'Could not open the link');
    }
  }

  // Share the brochure link with someone on WhatsApp
  Future<void> shareOnWhatsapp(BrochureModel b) async {
    try {
      final text = Uri.encodeComponent('${b.title}\n${b.url}');
      final ok = await launchUrl(
        Uri.parse('https://wa.me/?text=$text'),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) Get.snackbar('WhatsApp', 'Could not open WhatsApp');
    } catch (e) {
      Get.snackbar('WhatsApp', 'Could not open WhatsApp');
    }
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}