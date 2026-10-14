import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/infrastructures/constant/image_constant.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/models/lead_model.dart';
import 'package:muit_sales_app/res/brand.dart';
import 'package:muit_sales_app/wigets/app_background.dart';
import 'package:muit_sales_app/wigets/app_drawer.dart';
import 'package:muit_sales_app/wigets/custom_button.dart';

import '../controllers/dashboard_controller.dart';

// ---------- small helpers ----------
double _lerp(double a, double b, double t) => a + (b - a) * t;

double _c01(double v) => v < 0 ? 0.0 : (v > 1 ? 1.0 : v);

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Brand.canvas,
        drawer: const AppDrawer(),
        body: AppBackground(
          // Collapsing header: while scrolling, the big header shrinks to a slim bar,
          // the 2 stat tiles become a small pill, Quick Access shrinks into a dock,
          // and the rest of the content slides under the dock.
          child: _CollapsingDashboard(
            onRefresh: controller.refreshDashboard,
            menuButton: _menuButton(),
            logo: _logo(),
            miniStats: _miniStats(),
            statTiles: _statTiles,
            quickTitle: _blockTitle('Quick Access'),
            quickTiles: _quickTiles,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Visit Photo & Location card hidden for now.
                // To show it again, un-comment the next two lines:
                // _photoCard(),
                // const SizedBox(height: 24),
                _leadStatus(),
                const SizedBox(height: 24),
                _followUps(),
                const SizedBox(height: 24),
                _excelCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- HEADER PIECES (menu button, logo, small stat pill) ----------
  Widget _menuButton() {
    return Builder(
      builder: (ctx) => InkWell(
        onTap: () => Scaffold.of(ctx).openDrawer(),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: const Center(child: _MenuIcon()),
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        ImageConstants.muitLogo,
        height: 28,
        fit: BoxFit.contain,
      ),
    );
  }

  // shows when the header is collapsed: visits | leads
  Widget _miniStats() {
    const textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
      child: Obx(() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_walk, size: 14, color: Brand.gold),
          const SizedBox(width: 3),
          Text('${controller.todayVisits.value}', style: textStyle),
          Container(
            width: 1,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: const Color(0x40FFFFFF),
          ),
          const Icon(Icons.people_alt_outlined,
              size: 14, color: Brand.gold),
          const SizedBox(width: 3),
          Text('${controller.totalLeads.value}', style: textStyle),
        ],
      )),
    );
  }

  // ---------- COMMON CARD STYLE (white card, hairline border, soft shadow) ----------
  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Brand.hairline, width: 1),
        boxShadow: Brand.softShadow,
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title, {String? subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Brand.gold,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: Brand.maroonDeep),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Brand.ink,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12.5, color: Brand.inkSoft),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _blockTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: Brand.ink,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // white round icon chip used by the stat tiles and quick tiles
  Widget _iconCircle(IconData icon, double size, double iconSize) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: Brand.maroonDeep),
    );
  }

  // ---------- STAT TILES (gold cards: icon on the left, number + label on the right) ----------
  Widget _statTiles() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _statTile(
            "Today's Visits",
            controller.todayVisits,
            Icons.directions_walk,
            onTap: () => controller.openRoute(AppRoutes.visitEntry),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            'Total Leads',
            controller.totalLeads,
            Icons.people_alt_outlined,
            onTap: () => controller.openRoute(AppRoutes.leads),
          ),
        ),
      ],
    );
  }

  Widget _statTile(String title, RxInt value, IconData icon,
      {required VoidCallback onTap}) {
    final radius = BorderRadius.circular(22);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Brand.goldSoft, Brand.gold],
        ),
        borderRadius: radius,
        border: Border.all(color: Brand.ink, width: 1),
        boxShadow: [
          BoxShadow(
            color: Brand.maroon.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _iconCircle(icon, 44, 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => TweenAnimationBuilder<int>(
                        key: ValueKey(
                            '${controller.statsTick.value}_${value.value}'),
                        tween: IntTween(begin: 0, end: value.value),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        builder: (context, val, _) => Text(
                          '$val',
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Brand.ink,
                          ),
                        ),
                      )),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Brand.goldInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- PHOTO + LOCATION CARD (currently hidden, kept intact) ----------
  Widget _photoCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(Icons.photo_camera_outlined, 'Visit Photo & Location'),
          const SizedBox(height: 14),

          // steps: Photo -> Location -> Submit
          _stepper(),
          const SizedBox(height: 14),

          // photo preview
          Obx(() {
            final file = controller.photo.value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 200,
                color: Brand.blush,
                child: file == null
                    ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 50, color: Brand.inkSoft),
                      SizedBox(height: 8),
                      Text(
                        'No photo captured',
                        style: TextStyle(color: Brand.inkSoft),
                      ),
                    ],
                  ),
                )
                    : Image.file(file, fit: BoxFit.cover),
              ),
            );
          }),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            style: Brand.outlinedButton(),
            onPressed: controller.capturePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Photo'),
          ),
          const SizedBox(height: 12),

          // location info
          Obx(() {
            if (controller.isLocating.value) {
              return const Row(
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Brand.maroon,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Fetching location...',
                    style: TextStyle(color: Brand.inkSoft),
                  ),
                ],
              );
            }
            if (controller.address.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _infoRow(Icons.my_location, 'Latitude',
                    controller.lat.value.toStringAsFixed(6)),
                _infoRow(Icons.my_location, 'Longitude',
                    controller.lng.value.toStringAsFixed(6)),
                _infoRow(Icons.location_on, 'Address',
                    controller.address.value),
              ],
            );
          }),
          const SizedBox(height: 12),

          Obx(() => CustomButton(
            label: 'Submit Visit Photo',
            color: Brand.maroon,
            isLoading: controller.isUploadingPhoto.value,
            onPressed: controller.submitPhoto,
          )),
        ],
      ),
    );
  }

  // ---------- STEPPER (1 Photo - 2 Location - 3 Submit) ----------
  Widget _stepper() {
    return Obx(() {
      final step = controller.photo.value == null
          ? 1
          : (controller.address.value.isEmpty ? 2 : 3);
      return Row(
        children: [
          _stepItem(1, 'Photo', step),
          _stepLine(),
          _stepItem(2, 'Location', step),
          _stepLine(),
          _stepItem(3, 'Submit', step),
        ],
      );
    });
  }

  Widget _stepItem(int n, String label, int current) {
    final done = n <= current;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? Brand.maroon : Brand.maroonTint,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$n',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: done ? Colors.white : Brand.maroon,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Brand.inkSoft),
        ),
      ],
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: Brand.hairlineStrong,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Brand.maroon),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Brand.ink,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Brand.inkSoft),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- QUICK ACCESS TILES (CRM + CRM Fees) ----------
  // p = 0 -> full tile (icon + title + subtitle)
  // p = 1 -> compact dock button (icon + title only)
  Widget _quickTiles(double p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _quickTile(
            icon: Icons.support_agent,
            title: 'CRM',
            subtitle: 'Manage your leads',
            dark: true,
            p: p,
            onTap: () => controller.openRoute(AppRoutes.leads),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickTile(
            icon: Icons.currency_rupee,
            title: 'CRM Fees',
            subtitle: 'View fee details',
            dark: false,
            p: p,
            onTap: () => controller.openRoute(AppRoutes.fees),
          ),
        ),
      ],
    );
  }

  Widget _quickTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool dark,
    required double p,
    required VoidCallback onTap,
  }) {
    final radius = BorderRadius.circular(22);
    final circle = _lerp(44, 34, p);
    final iconSize = _lerp(22, 18, p);
    final subOpacity = _c01(1 - p * 1.8);
    final subFactor = _c01(1 - p);

    return Container(
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Brand.maroonLight, Brand.maroonDeep],
        )
            : null,
        color: dark ? null : Brand.goldTint,
        borderRadius: radius,
        border: Border.all(color: Brand.ink, width: 1),
        boxShadow: dark
            ? [
          BoxShadow(
            color: Brand.maroon.withValues(alpha: 0.26),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _iconCircle(icon, circle, iconSize),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: _lerp(16, 14.5, p),
                          fontWeight: FontWeight.w800,
                          color: dark ? Colors.white : Brand.ink,
                        ),
                      ),
                      ClipRect(
                        child: Align(
                          alignment: Alignment.topLeft,
                          heightFactor: subFactor,
                          child: Opacity(
                            opacity: subOpacity,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark
                                      ? const Color(0xFFF0CBD5)
                                      : Brand.inkSoft,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- LEAD STATUS (live counts from leads, boxes are tappable) ----------
  Widget _leadStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _blockTitle(
          'Lead Status',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => controller.isLoadingLeads.value
                  ? const SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Brand.maroon,
                ),
              )
                  : const Icon(Icons.circle, size: 8, color: Brand.gold)),
              const SizedBox(width: 4),
              const Text(
                'Live',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Brand.goldText,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: controller.loadStats,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.refresh, size: 20, color: Brand.inkSoft),
                ),
              ),
            ],
          ),
        ),
        _glassCard(
          child: Obx(() {
            final enquiry = controller.enquiryCount.value;
            final followUp = controller.followUpCount.value;
            final admission = controller.admissionCount.value;
            final total = controller.totalLeads.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: _StatusGauge(
                    enquiry: enquiry,
                    followUp: followUp,
                    admission: admission,
                    total: total,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statusCell(
                        'Enquiry',
                        enquiry,
                            () => controller.openLeadsWithStatus('Enquiry'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statusCell(
                        'Follow-up',
                        followUp,
                            () => controller.openLeadsWithStatus('Follow-up'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statusCell(
                        'Admission',
                        admission,
                            () => controller.openLeadsWithStatus('Admission'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _statusCell(String label, int count, VoidCallback onTap) {
    return Material(
      color: Brand.statusTint(label),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Brand.statusColor(label),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Brand.statusText(label),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Brand.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- FOLLOW-UPS DUE (aaj + overdue, top 10, small cards, horizontal scroll) ----------
  Widget _followUps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _blockTitle(
          'Follow-ups Due (top 10)',
          trailing: InkWell(
            onTap: () => controller.openRoute(AppRoutes.leads),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'View all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Brand.maroon,
                ),
              ),
            ),
          ),
        ),
        Obx(() {
          final list = controller.todayFollowUps;

          if (controller.isLoadingLeads.value && list.isEmpty) {
            return const SizedBox(
              height: 70,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Brand.maroon,
                ),
              ),
            );
          }

          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Brand.hairline, width: 1),
              ),
              child: const Center(
                child: Text(
                  'No follow-ups due',
                  style: TextStyle(color: Brand.inkSoft),
                ),
              ),
            );
          }

          return SizedBox(
            height: 214,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _followUpCard(list[i]),
            ),
          );
        }),
      ],
    );
  }

  Widget _followUpCard(LeadModel lead) {
    final days = controller.overdueDays(lead);
    final isOverdue = days > 0;
    final stripBg = isOverdue ? Brand.dangerTint : Brand.goldChip;
    final stripFg = isOverdue ? Brand.danger : Brand.goldText;
    final dueText = !isOverdue
        ? 'Due today'
        : (days == 1 ? 'Overdue 1 day' : 'Overdue $days days');

    return SizedBox(
      width: 276,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Brand.hairline, width: 1),
          boxShadow: Brand.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => controller.openLead(lead),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // due strip
                  Container(
                    color: stripBg,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 14, color: stripFg),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dueText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: stripFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Brand.gold,
                              foregroundColor: Brand.maroonDeep,
                              child: Text(
                                lead.name.isNotEmpty
                                    ? lead.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lead.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Brand.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            BrandChip(
                              label: lead.status,
                              background: Brand.statusTint(lead.status),
                              foreground: Brand.statusText(lead.status),
                              fontSize: 11,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${lead.course}  •  ${lead.phone}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: Brand.ink),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lead.schoolCollege.isEmpty ? '-' : lead.schoolCollege,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Brand.inkSoft),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => controller.callLead(lead),
                                icon: const Icon(Icons.call, size: 18),
                                label: const Text('Call'),
                                style: Brand.maroonButton(vertical: 11),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 44,
                              height: 42,
                              child: OutlinedButton(
                                onPressed: () => controller.openLead(lead),
                                style: Brand.outlinedButton(
                                    radius: 12, vertical: 0)
                                    .copyWith(
                                  padding: const WidgetStatePropertyAll(
                                      EdgeInsets.zero),
                                ),
                                child: const Icon(Icons.arrow_forward_rounded,
                                    size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- EXCEL CARD (download sample -> choose file -> upload) ----------
  Widget _excelCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(
            Icons.table_chart_outlined,
            'Excel Upload (Leads)',
            subtitle: 'Import leads in bulk',
          ),
          const SizedBox(height: 16),

          // step 2 : the chosen Excel (dashed drop zone)
          CustomPaint(
            painter: const _DashedBorderPainter(
              color: Brand.blushBorder,
              radius: 20,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Brand.blush,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Brand.maroonTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.upload_file,
                        size: 22, color: Brand.maroon),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    controller.excel.value?.name ?? 'No file selected',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Brand.ink,
                    ),
                  )),
                  const SizedBox(height: 2),
                  const Text(
                    'Supports .xlsx and .xls',
                    style: TextStyle(fontSize: 12.5, color: Brand.inkSoft),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // step 1 : download the sample Excel
              Expanded(
                child: Obx(() => OutlinedButton.icon(
                  style: Brand.outlinedButton(vertical: 14),
                  onPressed: controller.isDownloadingSample.value
                      ? null
                      : controller.downloadSample,
                  icon: controller.isDownloadingSample.value
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Brand.maroon,
                    ),
                  )
                      : const Icon(Icons.download, size: 18),
                  label: const Text('Sample Excel'),
                )),
              ),
              const SizedBox(width: 10),
              // choose the filled Excel
              Expanded(
                child: OutlinedButton.icon(
                  style: Brand.outlinedButton(vertical: 14),
                  onPressed: controller.pickExcel,
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text('Choose File'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // step 3 : upload
          Obx(() => BrandGoldButton(
            label: 'Upload File',
            isLoading: controller.isUploadingExcel.value,
            onPressed: controller.uploadExcel,
          )),
        ],
      ),
    );
  }
}

// ---------- GOLD DECOR (header glow + rings) ----------
Widget _goldGlow(double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          Brand.gold.withValues(alpha: 0.35),
          Brand.gold.withValues(alpha: 0.0),
        ],
      ),
    ),
  );
}

Widget _goldRing(double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Brand.gold.withValues(alpha: 0.26)),
    ),
  );
}

// ---------- SEMICIRCLE GAUGE (Enquiry / Follow-up / Admission) ----------
class _StatusGauge extends StatelessWidget {
  final int enquiry;
  final int followUp;
  final int admission;
  final int total;

  const _StatusGauge({
    required this.enquiry,
    required this.followUp,
    required this.admission,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 132,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GaugePainter(
                enquiry: enquiry,
                followUp: followUp,
                admission: admission,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 38,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: Brand.ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Total leads',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Brand.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int enquiry;
  final int followUp;
  final int admission;

  const _GaugePainter({
    required this.enquiry,
    required this.followUp,
    required this.admission,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 20.0;
    final center = Offset(size.width / 2, size.height - 4);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFFF3E8EB);
    canvas.drawArc(rect, math.pi, math.pi, false, track);

    final sum = enquiry + followUp + admission;
    if (sum == 0) return;

    final parts = <MapEntry<int, Color>>[
      MapEntry(enquiry, Brand.statusColor('Enquiry')),
      MapEntry(followUp, Brand.statusColor('Follow-up')),
      MapEntry(admission, Brand.statusColor('Admission')),
    ].where((e) => e.key > 0).toList();

    final gap = parts.length > 1 ? 0.04 : 0.0;
    var start = math.pi;
    for (final p in parts) {
      final sweep = math.pi * p.key / sum;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = p.value;
      canvas.drawArc(rect, start + gap / 2, sweep - gap, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.enquiry != enquiry ||
          old.followUp != followUp ||
          old.admission != admission;
}

// ---------- DASHED ROUNDED BORDER (Excel drop zone) ----------
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

// ---------- CLIPS EVERYTHING ABOVE [top] (content slides under the dock) ----------
class _TopClipper extends CustomClipper<Rect> {
  final double top;

  const _TopClipper(this.top);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, math.min(top, size.height), size.width, size.height);

  @override
  bool shouldReclip(covariant _TopClipper old) => old.top != top;
}

// ---------- COLLAPSING HEADER + QUICK ACCESS DOCK + SCROLLING CONTENT ----------
//
// Scroll offset 0   : big maroon header, 2 stat tiles, Quick Access cards, then content.
// While scrolling   : header shrinks to a slim bar, stat tiles fade away and become a small
//                     "visits | leads" pill inside the bar, Quick Access cards move up and
//                     shrink into a compact dock, the rest of the content slides under it.
// Scroll back down  : everything expands back exactly as before.
class _CollapsingDashboard extends StatefulWidget {
  final Widget child; // content below Quick Access
  final Future<void> Function() onRefresh;
  final Widget menuButton;
  final Widget logo;
  final Widget miniStats;
  final Widget Function() statTiles;
  final Widget quickTitle;
  final Widget Function(double p) quickTiles;

  const _CollapsingDashboard({
    required this.child,
    required this.onRefresh,
    required this.menuButton,
    required this.logo,
    required this.miniStats,
    required this.statTiles,
    required this.quickTitle,
    required this.quickTiles,
  });

  @override
  State<_CollapsingDashboard> createState() => _CollapsingDashboardState();
}

class _CollapsingDashboardState extends State<_CollapsingDashboard> {
  final ScrollController _sc = ScrollController();

  // sizes (dp)
  static const double _barH = 44; // menu button height
  static const double _tileH = 72; // stat tile height
  static const double _quickH = 72; // quick tile height (expanded)
  static const double _dockH = 52; // quick tile height (collapsed dock)
  static const double _titleH = 34; // "Quick Access" title block height

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  // dragging on the header / tiles / dock should also scroll the page
  void _onDrag(DragUpdateDetails d) {
    if (!_sc.hasClients) return;
    final pos = _sc.position;
    final next = (pos.pixels - d.delta.dy)
        .clamp(pos.minScrollExtent, pos.maxScrollExtent)
        .toDouble();
    pos.jumpTo(next);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_sc.hasClients) return;
    final pos = _sc.position;
    if (pos is ScrollPositionWithSingleContext) {
      pos.goBallistic(-(d.primaryVelocity ?? 0));
    }
  }

  Widget _drag(Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: _onDrag,
      onVerticalDragEnd: _onDragEnd,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    // ---- layout maths ----
    final topPartH = top + 144; // maroon part above the stat tiles
    final hExp = topPartH + _tileH / 2; // expanded header height
    final hCol = top + 66; // collapsed header height
    final tilesTop0 = topPartH;
    final qTop0 = tilesTop0 + _tileH + 20 + _titleH; // quick tiles start
    final qPinned = hCol + 8; // quick dock final position
    final pinDist = qTop0 - qPinned; // scroll distance for the full collapse
    final contentTop = qTop0 + _quickH + 24; // where the rest of the content starts

    return LayoutBuilder(
      builder: (context, box) {
        return AnimatedBuilder(
          animation: _sc,
          builder: (context, _) {
            final raw = _sc.hasClients ? _sc.offset : 0.0;
            final p = _c01(raw / pinDist);
            final e = Curves.easeInOut.transform(p);
            final pv = math.min(math.max(raw, 0.0), pinDist);

            final hh = _lerp(hExp, hCol, e);
            final radius = _lerp(36, 24, e);
            final qy = math.max(qPinned, qTop0 - raw);
            final qh = _lerp(_quickH, _dockH, e);
            final clipTop = qy + qh + 8;
            final fade = math.max(1.0, 14 * e);
            final statOpacity = _c01(1 - p * 2.2);

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1) maroon header (gradient + gold rings with parallax)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: hh,
                  child: _drag(
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: const [
                            Brand.maroonDarkest,
                            Brand.maroonMid,
                          ],
                          stops: [0.0, _c01(topPartH / hh)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(radius),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                              top: -100 - pv * 0.25,
                              right: -80,
                              child: _goldGlow(300)),
                          Positioned(
                              top: -60 - pv * 0.45,
                              right: -40,
                              child: _goldRing(220)),
                          Positioned(
                              top: -20 - pv * 0.7,
                              right: 0,
                              child: _goldRing(140)),
                          Positioned(
                            left: 16,
                            top: top + 76 - 8 * e,
                            child: Opacity(
                              opacity: _c01(1 - p * 2.2),
                              child: const Text(
                                'Welcome to',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFF0CBD5),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            top: top + 94 - 22 * e,
                            child: Opacity(
                              opacity: _c01(1 - p * 1.8),
                              child: Transform.scale(
                                scale: 1 - 0.2 * e,
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  'Sales Dashboard',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2) stat tiles (fade + shrink while scrolling)
                Positioned(
                  left: 16,
                  right: 16,
                  top: tilesTop0 - 28 * e,
                  height: _tileH,
                  child: IgnorePointer(
                    ignoring: statOpacity < 0.05,
                    child: Opacity(
                      opacity: statOpacity,
                      child: Transform.scale(
                        scale: 1 - 0.1 * e,
                        child: _drag(widget.statTiles()),
                      ),
                    ),
                  ),
                ),

                // 3) scrolling content (clipped, slides under the dock)
                Positioned.fill(
                  child: ClipRect(
                    clipper: _TopClipper(clipTop),
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (rect) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const [Color(0x00000000), Color(0xFF000000)],
                        stops: [
                          _c01(clipTop / rect.height),
                          _c01((clipTop + fade) / rect.height),
                        ],
                      ).createShader(rect),
                      child: RefreshIndicator(
                        color: Brand.maroon,
                        edgeOffset: contentTop,
                        onRefresh: widget.onRefresh,
                        child: SingleChildScrollView(
                          controller: _sc,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16, contentTop, 16, 24),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),

                // 4) Quick Access title + tiles (move up, then shrink into a dock)
                Positioned(
                  left: 16,
                  right: 16,
                  top: qy - _titleH,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: _c01(1 - p * 2.4),
                      child: widget.quickTitle,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: qy,
                  height: qh,
                  child: _drag(widget.quickTiles(e)),
                ),

                // 5) top bar: menu button, logo, and the small stat pill
                Positioned(
                  top: top + 12,
                  left: 16,
                  right: 16,
                  height: _barH,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: widget.menuButton,
                      ),
                      Center(child: widget.logo),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: _c01((p - 0.55) / 0.45),
                            child: widget.miniStats,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ---------- DRAWER (MENU) ICON: 3 lines, last one shorter ----------
class _MenuIcon extends StatelessWidget {
  const _MenuIcon();

  Widget _line(double width) => Container(
    width: width,
    height: 2.2,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _line(20),
        const SizedBox(height: 5),
        _line(20),
        const SizedBox(height: 5),
        _line(12),
      ],
    );
  }
}