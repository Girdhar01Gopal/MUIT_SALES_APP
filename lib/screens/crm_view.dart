import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/wigets/app_background.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';
import 'package:muit_sales_app/wigets/custom_dropdown.dart';
import 'package:muit_sales_app/wigets/custom_text_field.dart';

import '../controllers/crm_controller.dart';

class CrmView extends GetView<CrmController> {
  const CrmView({super.key});

  static final RoundedRectangleBorder _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: Colors.black, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    final lead = controller.lead;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('CRM - Student Details', style: TextStyle(color: Colors.white)),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headerCard(),
            const SizedBox(height: 12),
            _actionButtons(context),
            const SizedBox(height: 12),
            _studentDetailsCard(),
            const SizedBox(height: 12),
            _updatePipelineCard(),
            const SizedBox(height: 12),
            _timelineNotesCard(),
          ],
        ),
      ),
    );
  }

  // ---------- HEADER WITH PRIORITY BADGES ----------
  Widget _headerCard() {
    final lead = controller.lead;

    return Card(
      color: Colors.white,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              child: Text(
                lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${lead.course} • ${lead.campus} Campus',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                  if (lead.schoolCollege.isNotEmpty)
                    Text(
                      lead.schoolCollege,
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                ],
              ),
            ),
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _badgeWidget(controller.status.value, _statusColor(controller.status.value)),
                const SizedBox(height: 6),
                _badgeWidget('${_priorityEmoji(controller.priority.value)} ${controller.priority.value}', _priorityColor(controller.priority.value)),
              ],
            )),
          ],
        ),
      ),
    );
  }

  // ---------- SMART ACTION BUTTONS ----------
  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.call,
            icon: const Icon(Icons.call, color: Colors.white),
            label: const Text('Call Student', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showWhatsAppMenu(context),
            icon: const Icon(Icons.chat, color: Colors.white),
            label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- STUDENT DETAILS CARD ----------
  Widget _studentDetailsCard() {
    final lead = controller.lead;
    return Card(
      color: Colors.white,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _infoRow(Icons.phone, 'Phone', lead.phone),
            _infoRow(Icons.menu_book, 'Course Interest', lead.course),
            _infoRow(Icons.location_city, 'Campus Preference', lead.campus),
            if (lead.source.isNotEmpty)
              _infoRow(Icons.campaign_outlined, 'Lead Source', lead.source),
            if (lead.schoolCollege.isNotEmpty)
              _infoRow(Icons.school, 'School/College', lead.schoolCollege),
          ],
        ),
      ),
    );
  }

  // ---------- PIPELINE & SCHEDULE CARD ----------
  Widget _updatePipelineCard() {
    return Card(
      color: Colors.white,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lead Pipeline & Schedule Update',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // FIX: Row ki jagah Column, taaki dropdown ko poori width mile
            Obx(() => CustomDropdown(
              label: 'Status',
              items: controller.statuses,
              value: controller.status.value,
              prefixIcon: Icons.flag_outlined,
              onChanged: (v) {
                if (v != null) controller.status.value = v;
              },
            )),
            const SizedBox(height: 10),
            Obx(() => CustomDropdown(
              label: 'Priority',
              items: controller.priorities,
              value: controller.priority.value,
              prefixIcon: Icons.local_fire_department,
              onChanged: (v) {
                if (v != null) controller.priority.value = v;
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
              label: 'Campus Visit Scheduled Date',
              controller: controller.campusVisitCtrl,
              readOnly: true,
              prefixIcon: Icons.domain,
              suffixIcon: const Icon(Icons.edit_calendar),
              onTap: controller.pickCampusVisitDate,
            ),

            const SizedBox(height: 8),
            Obx(() => CustomButton(
              label: 'Save Changes',
              isLoading: controller.isSaving.value,
              onPressed: controller.saveChanges,
            )),
          ],
        ),
      ),
    );
  }

  // ---------- ACTIVITY TIMELINE & NOTES ----------
  Widget _timelineNotesCard() {
    return Card(
      color: Colors.white,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Activity & Conversation History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CustomTextField(
              label: 'Add conversation note...',
              controller: controller.noteCtrl,
              maxLines: 2,
              prefixIcon: Icons.edit_note,
            ),
            const SizedBox(height: 6),
            Obx(() => CustomButton(
              label: 'Add Note',
              isLoading: controller.isAddingNote.value,
              onPressed: controller.addNote,
            )),
            const SizedBox(height: 14),

            Obx(() {
              if (controller.notes.isEmpty) {
                return const Text('No history recorded yet', style: TextStyle(color: AppColors.textGrey));
              }
              return Column(
                children: controller.notes.map((n) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.text, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.access_time, size: 12, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(n.date, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------- WHATSAPP TEMPLATE DIALOG ----------
  void _showWhatsAppMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select WhatsApp Template', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.school, color: AppColors.darkBlue),
              title: const Text('General Course Enquiry Template'),
              subtitle: const Text('MUIT welcome message & course info'),
              onTap: () {
                Get.back();
                controller.whatsappTemplate('general');
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_rupee, color: AppColors.success),
              title: const Text('Fee Structure & Scholarship Template'),
              subtitle: const Text('Share fee info link with student'),
              onTap: () {
                Get.back();
                controller.whatsappTemplate('fees');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: AppColors.secondary),
              title: const Text('Campus Visit Invitation Template'),
              subtitle: const Text('Invite student for campus tour'),
              onTap: () {
                Get.back();
                controller.whatsappTemplate('visit');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- HELPERS ----------
  Widget _badgeWidget(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.darkBlue),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
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
        return AppColors.darkBlue;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Hot':
        return Colors.red;
      case 'Warm':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _priorityEmoji(String priority) {
    switch (priority) {
      case 'Hot':
        return '🔥';
      case 'Warm':
        return '⚡';
      default:
        return '❄️';
    }
  }
}