import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/models/note_model.dart';
import 'package:muit_sales_app/repo/crm_repo.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/log_services.dart';
import 'leads_controller.dart';

class CrmController extends GetxController {
  final CrmRepo _repo = CrmRepo();

  late final LeadModel lead;

  final List<String> statuses = ['Enquiry', 'Follow-up', 'Admission'];
  final List<String> priorities = ['Hot', 'Warm', 'Cold'];

  final RxString status = 'Enquiry'.obs;
  final RxString priority = 'Warm'.obs;

  final followUpCtrl = TextEditingController();
  final campusVisitCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxBool isSaving = false.obs;
  final RxBool isAddingNote = false.obs;

  @override
  void onInit() {
    super.onInit();
    lead = Get.arguments as LeadModel;

    status.value = statuses.contains(lead.status) ? lead.status : 'Enquiry';
    priority.value = priorities.contains(lead.priority) ? lead.priority : 'Warm';

    followUpCtrl.text = lead.followUpDate;
    campusVisitCtrl.text = lead.campusVisitDate;

    if (lead.remarks.isNotEmpty) {
      notes.add(NoteModel(
          text: '[Field Visit Remark]: ${lead.remarks}', date: 'Visit Time'));
    }
  }

  // ---------- CALL ACTION WITH LOGGING ----------

  Future<void> call() async {
    try {
      final ok = await launchUrl(Uri(scheme: 'tel', path: lead.phone));
      if (ok) {
        _addSystemNote('📞 Called ${lead.name} (${lead.phone})');

        if (Get.isRegistered<LogService>()) {
          LogService.to.addLog(
            actionType: 'CALL',
            description: 'Called student ${lead.name} (${lead.phone})',
            extraData: {'lead_id': lead.id},
          );
        }
      } else {
        Get.snackbar('Call', 'Could not start the call');
      }
    } catch (e) {
      Get.snackbar('Call', 'Could not start the call');
    }
  }

  // ---------- SMART WHATSAPP TEMPLATES ----------

  Future<void> whatsappTemplate(String messageType) async {
    String text = '';
    final name = lead.name;
    final course = lead.course;

    switch (messageType) {
      case 'general':
        text =
        "Hello $name,\nMaharishi University (MUIT) mein aapka swagat hai! $course course ke regarding kisi bhi jaankari ke liye aap humse sampark kar sakte hain.";
        break;
      case 'fees':
        text =
        "Hello $name,\nMUIT $course course ka Fee Structure aur Scholarship options janne ke liye link par click karein ya humse baat karein.";
        break;
      case 'visit':
        text =
        "Hello $name,\nAapko Maharishi University (MUIT) Campus visit ke liye aamantrit kiya jata hai. Campus visit schedule karne ke liye reply karein.";
        break;
    }

    try {
      final number = lead.phone.length == 10 ? '91${lead.phone}' : lead.phone;
      final encodedText = Uri.encodeComponent(text);
      final url = 'https://wa.me/$number?text=$encodedText';

      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (ok) {
        _addSystemNote('💬 Sent WhatsApp ($messageType template) to $name');

        if (Get.isRegistered<LogService>()) {
          LogService.to.addLog(
            actionType: 'WHATSAPP',
            description: 'Sent $messageType WhatsApp template to $name',
            extraData: {'phone': lead.phone},
          );
        }
      } else {
        Get.snackbar('WhatsApp', 'Could not open WhatsApp');
      }
    } catch (e) {
      Get.snackbar('WhatsApp', 'Could not open WhatsApp');
    }
  }

  // ---------- DATE PICKERS ----------

  Future<void> pickFollowUpDate() async {
    final d = await _selectDate();
    if (d != null) {
      followUpCtrl.text = '${d.year}-${_two(d.month)}-${_two(d.day)}';
    }
  }

  Future<void> pickCampusVisitDate() async {
    final d = await _selectDate();
    if (d != null) {
      campusVisitCtrl.text = '${d.year}-${_two(d.month)}-${_two(d.day)}';
    }
  }

  Future<DateTime?> _selectDate() async {
    final now = DateTime.now();
    return await showDatePicker(
      context: Get.context!,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  // ---------- SAVE CHANGES ----------

  Future<void> saveChanges() async {
    try {
      isSaving.value = true;

      final ok = await _repo.updateLead(
        id: lead.id,
        status: status.value,
        followUpDate: followUpCtrl.text.trim(),
      );

      if (ok) {
        if (Get.isRegistered<LeadsController>()) {
          Get.find<LeadsController>().updateLocal(
            lead.id,
            status.value,
            followUpCtrl.text.trim(),
            priority: priority.value,
            campusVisitDate: campusVisitCtrl.text.trim(),
          );
        }

        if (Get.isRegistered<LogService>()) {
          LogService.to.addLog(
            actionType: 'STATUS_CHANGE',
            description:
            'Updated lead ${lead.name} status to ${status.value}',
          );
        }

        Get.back();
        Get.snackbar('Success', 'Lead details updated successfully');
      } else {
        Get.snackbar('Error', 'Update failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Update failed');
    } finally {
      isSaving.value = false;
    }
  }

  // ---------- NOTES / TIMELINE ----------

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
        Get.snackbar('Error', 'Could not save note');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save note');
    } finally {
      isAddingNote.value = false;
    }
  }

  void _addSystemNote(String msg) {
    notes.insert(0, NoteModel(text: msg, date: _now()));
  }

  String _now() {
    final n = DateTime.now();
    return '${n.year}-${_two(n.month)}-${_two(n.day)} ${_two(n.hour)}:${_two(n.minute)}';
  }

  @override
  void onClose() {
    followUpCtrl.dispose();
    campusVisitCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}