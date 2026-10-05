import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/models/note_model.dart';
import 'package:muit_sales_app/repo/crm_repo.dart';
import 'package:url_launcher/url_launcher.dart';

import 'leads_controller.dart';

class CrmController extends GetxController {
  final CrmRepo _repo = CrmRepo();

  late final LeadModel lead;

  final List<String> statuses = ['Enquiry', 'Follow-up', 'Admission'];

  final RxString status = 'Enquiry'.obs;
  final followUpCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxBool isSaving = false.obs;
  final RxBool isAddingNote = false.obs;

  @override
  void onInit() {
    super.onInit();
    lead = Get.arguments as LeadModel;

    status.value = statuses.contains(lead.status) ? lead.status : 'Enquiry';
    followUpCtrl.text = lead.followUpDate;

    // The remark from the visit becomes the first note
    if (lead.remarks.isNotEmpty) {
      notes.add(NoteModel(text: lead.remarks, date: 'At visit time'));
    }
  }

  // ---------- CALL / WHATSAPP ----------

  Future<void> call() async {
    try {
      final ok = await launchUrl(Uri(scheme: 'tel', path: lead.phone));
      if (!ok) Get.snackbar('Call', 'Could not start the call');
    } catch (e) {
      Get.snackbar('Call', 'Could not start the call');
    }
  }

  Future<void> whatsapp() async {
    try {
      // Add 91 (India) before a 10-digit number
      final number = lead.phone.length == 10 ? '91${lead.phone}' : lead.phone;
      final ok = await launchUrl(
        Uri.parse('https://wa.me/$number'),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) Get.snackbar('WhatsApp', 'Could not open WhatsApp');
    } catch (e) {
      Get.snackbar('WhatsApp', 'Could not open WhatsApp');
    }
  }

  // ---------- FOLLOW-UP DATE ----------

  Future<void> pickFollowUpDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: Get.context!,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d == null) return;
    followUpCtrl.text = '${d.year}-${_two(d.month)}-${_two(d.day)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  // ---------- STATUS / DATE SAVE ----------

  Future<void> saveChanges() async {
    try {
      isSaving.value = true;

      final ok = await _repo.updateLead(
        id: lead.id,
        status: status.value,
        followUpDate: followUpCtrl.text.trim(),
      );

      if (ok) {
        // Also update the leads list immediately
        if (Get.isRegistered<LeadsController>()) {
          Get.find<LeadsController>()
              .updateLocal(lead.id, status.value, followUpCtrl.text.trim());
        }
        Get.back(); // close the screen first, then show the snackbar
        Get.snackbar('Success', 'Lead updated');
      } else {
        Get.snackbar('Error', 'Update failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Update failed');
    } finally {
      isSaving.value = false;
    }
  }

  // ---------- NOTES ----------

  Future<void> addNote() async {
    final text = noteCtrl.text.trim();
    if (text.isEmpty) return;

    try {
      isAddingNote.value = true;
      final ok = await _repo.addNote(leadId: lead.id, note: text);

      if (ok) {
        notes.insert(0, NoteModel(text: text, date: _now()));
        noteCtrl.clear();
      } else {
        Get.snackbar('Error', 'Could not save the note');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save the note');
    } finally {
      isAddingNote.value = false;
    }
  }

  String _now() {
    final n = DateTime.now();
    return '${n.year}-${_two(n.month)}-${_two(n.day)} ${_two(n.hour)}:${_two(n.minute)}';
  }

  @override
  void onClose() {
    followUpCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}