import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/res/brand.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';
import 'package:muit_sales_app/wigets/custom_dropdown.dart';
import 'package:muit_sales_app/wigets/custom_text_field.dart';

import '../controllers/crm_controller.dart';

class CrmView extends GetView<CrmController> {
  const CrmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.canvas,
      appBar: Brand.appBar('CRM - Student Details'),
      body: BrandBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headerCard(),
            const SizedBox(height: 14),
            _actionButtons(context),
            const SizedBox(height: 14),
            _studentDetailsCard(),
            const SizedBox(height: 14),
            _updatePipelineCard(),
            const SizedBox(height: 14),
            _timelineNotesCard(),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.hairline),
        boxShadow: Brand.softShadow,
      ),
      child: child,
    );
  }

  // ---------- HEADER WITH PRIORITY BADGES ----------
  Widget _headerCard() {
    final lead = controller.lead;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Brand.maroonLight, Brand.maroonDeep],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: Brand.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Brand.gold,
            foregroundColor: Brand.goldInk,
            child: Text(
              lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${lead.course} • ${lead.campus} Campus',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (lead.schoolCollege.isNotEmpty)
                  Text(
                    lead.schoolCollege,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
              ],
            ),
          ),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BrandChip(
                    label: controller.status.value,
                    background: Brand.statusTint(controller.status.value),
                    foreground: Brand.statusText(controller.status.value),
                  ),
                  const SizedBox(height: 6),
                  BrandChip(
                    label:
                        '${_priorityEmoji(controller.priority.value)} ${controller.priority.value}',
                    background: Colors.white,
                    foreground: Brand.priorityColor(controller.priority.value),
                  ),
                ],
              )),
        ],
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
            label: const Text('Call Student'),
            style: Brand.maroonButton(radius: 14, vertical: 14),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showWhatsAppMenu(context),
            icon: const Icon(Icons.chat, color: Brand.goldInk),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Brand.gold,
              foregroundColor: Brand.goldInk,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- STUDENT DETAILS CARD ----------
  Widget _studentDetailsCard() {
    final lead = controller.lead;
    return _card(
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
    );
  }

  // ---------- PIPELINE & SCHEDULE CARD ----------
  Widget _updatePipelineCard() {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Lead Pipeline & Schedule Update',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Brand.ink,
            ),
          ),
          const SizedBox(height: 12),

          // Column instead of Row so the dropdown gets the full width
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
                color: Brand.maroon,
                onPressed: controller.saveChanges,
              )),
        ],
      ),
    );
  }

  // ---------- ACTIVITY TIMELINE & NOTES ----------
  Widget _timelineNotesCard() {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Activity & Conversation History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Brand.ink,
            ),
          ),
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
                color: Brand.maroon,
                onPressed: controller.addNote,
              )),
          const SizedBox(height: 14),
          Obx(() {
            if (controller.notes.isEmpty) {
              return const Text(
                'No history recorded yet',
                style: TextStyle(color: Brand.inkSoft),
              );
            }
            return Column(
              children: controller.notes.map((n) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Brand.blush,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Brand.hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.text,
                        style:
                            const TextStyle(fontSize: 13, color: Brand.ink),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.access_time,
                              size: 12, color: Brand.inkSoft),
                          const SizedBox(width: 4),
                          Text(
                            n.date,
                            style: const TextStyle(
                                fontSize: 11, color: Brand.inkSoft),
                          ),
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
    );
  }

  // ---------- WHATSAPP TEMPLATE DIALOG ----------
  void _showWhatsAppMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select WhatsApp Template',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Brand.ink,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.school, color: Brand.maroon),
              title: const Text('General Course Enquiry Template'),
              subtitle: const Text('MUIT welcome message & course info'),
              onTap: () {
                Get.back();
                controller.whatsappTemplate('general');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.currency_rupee, color: Brand.goldText),
              title: const Text('Fee Structure & Scholarship Template'),
              subtitle: const Text('Share fee info link with student'),
              onTap: () {
                Get.back();
                controller.whatsappTemplate('fees');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Brand.roseText),
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
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: Brand.maroonTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Brand.maroon),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Brand.ink),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Brand.ink)),
          ),
        ],
      ),
    );
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
