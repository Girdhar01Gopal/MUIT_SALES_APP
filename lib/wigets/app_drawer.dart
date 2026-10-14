import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/res/app_strings.dart';
import 'package:muit_sales_app/res/brand.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer Header with Dashboard Maroon Gradient & Gold Ring decoration
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).padding.top + 170,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Brand.maroonDarkest, Brand.maroonMid],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: Stack(
                children: [
                  Positioned(top: -60, right: -40, child: _goldGlow(200)),
                  Positioned(top: -40, right: -20, child: _goldRing(160)),
                  Positioned(top: -10, right: 10, child: _goldRing(100)),
                  Positioned(bottom: -40, left: -30, child: _goldRing(120)),
                  SafeArea(
                    bottom: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Image.asset(
                          'assets/images/LogoMuit_without back.png',
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _item(Icons.dashboard, 'Dashboard', AppRoutes.dashboard,
              const Color(0xFF2563EB)), // blue
          _separator(),
          _item(Icons.people, 'Leads', AppRoutes.leads,
              const Color(0xFF16A34A)), // green
          _separator(),
          _item(Icons.edit_location_alt, 'Visit Entry', AppRoutes.visitEntry,
              const Color(0xFFEA580C)), // orange
          _separator(),
          _item(Icons.support_agent, 'CRM', AppRoutes.leads,
              const Color(0xFF7C3AED)), // purple
          _separator(),
          _item(Icons.upload_file, 'Excel Upload', AppRoutes.excelUpload,
              const Color(0xFF0D9488)), // teal
          _separator(),
          _item(Icons.picture_as_pdf, 'Brochure', AppRoutes.brochure,
              const Color(0xFFDB2777)), // pink
          _separator(),
          _item(Icons.currency_rupee, 'CRM Fees', AppRoutes.fees,
              const Color(0xFFD97706)),
          _separator(),
          _item(Icons.history_toggle_off, 'Activity Logs', AppRoutes.activityLogs,
              const Color(0xFF8B5CF6)),// amber
          const Spacer(),
          const Divider(),
          // Logout button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    GetStorage().remove(AppStrings.tokenKey);
                    Get.offAllNamed(AppRoutes.login);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _separator() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _item(IconData icon, String title, String? route, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Get.back();
        if (route == null) {
          Get.snackbar(title, 'Coming soon');
        } else if (Get.currentRoute != route) {
          Get.toNamed(route);
        }
      },
    );
  }
}