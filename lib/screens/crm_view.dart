import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';
import 'package:muit_sales_app/wigets/custom_dropdown.dart';
import 'package:muit_sales_app/wigets/custom_text_field.dart';

import '../controllers/crm_controller.dart';

class CrmView extends GetView<CrmController> {
  const CrmView({super.key});

  // White card with black border (same as other screens)
  static final RoundedRectangleBorder _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: Colors.black, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    final lead = controller.lead;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // light slate gray
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Lead Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // ---------- WATERMARK ----------
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/muit_spash_logo.webp',
                    width: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // ---------- CONTENT ----------
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _headerCard(),
              const SizedBox(height: 12),
              _contactButtons(),
              const SizedBox(height: 12),

              // details
              Card(
                color: Colors.white,
                shape: _cardShape,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _infoRow(Icons.phone, 'Phone', lead.phone),
                      _infoRow(Icons.menu_book, 'Course', lead.course),
                      if (lead.schoolCollege.isNotEmpty)
                        _infoRow(Icons.school, 'School/College',
                            lead.schoolCollege),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _updateCard(),
              const SizedBox(height: 12),
              _notesCard(),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- HEADER ----------
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
                style: const TextStyle(fontSize: 22),
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
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(lead.course,
                      style: const TextStyle(color: AppColors.textGrey)),
                ],
              ),
            ),
            Obx(() {
              final color = _statusColor(controller.status.value);
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.status.value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------- CALL / WHATSAPP ----------
  Widget _contactButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.call,
            icon: const Icon(Icons.call),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.whatsapp,
            icon: const Icon(Icons.chat),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- STATUS + FOLLOW-UP UPDATE ----------
  Widget _updateCard() {
    return Card(
      color: Colors.white,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Status / Follow-up Update',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => CustomDropdown(
              label: 'Status',
              items: controller.statuses,
              value: controller.status.value,
              prefixIcon: Icons.flag_outlined,
              onChanged: (v) {
                if (v != null) controller.status.value = v;
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

  // ---------- NOTES ----------
  Widget _notesCard() {
    return Card(
      color: Colors.white,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Write a new note',
              controller: controller.noteCtrl,
              maxLines: 2,
              prefixIcon: Icons.notes,
            ),
            const SizedBox(height: 4),
            Obx(() => CustomButton(
              label: 'Add Note',
              isLoading: controller.isAddingNote.value,
              onPressed: controller.addNote,
            )),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.notes.isEmpty) {
                return const Text(
                  'No notes yet',
                  style: TextStyle(color: AppColors.textGrey),
                );
              }
              return Column(
                children: controller.notes.map((n) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.text),
                        const SizedBox(height: 4),
                        Text(
                          n.date,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGrey),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.darkBlue),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
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
        return AppColors.darkBlue; // Enquiry
    }
  }
}