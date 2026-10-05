import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import 'package:muit_sales_app/res/app_colors.dart';
import 'package:muit_sales_app/res/app_strings.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(color: AppColors.darkBlueDeep),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  'assets/images/muit_spash_logo.webp',
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          _item(Icons.dashboard, 'Dashboard', AppRoutes.dashboard,
              const Color(0xFF2563EB)), // blue
          _item(Icons.people, 'Leads', AppRoutes.leads,
              const Color(0xFF16A34A)), // green
          _item(Icons.edit_location_alt, 'Visit Entry', AppRoutes.visitEntry,
              const Color(0xFFEA580C)), // orange
          _item(Icons.support_agent, 'CRM', AppRoutes.leads,
              const Color(0xFF7C3AED)), // purple
          _item(Icons.upload_file, 'Excel Upload', AppRoutes.excelUpload,
              const Color(0xFF0D9488)), // teal
          _item(Icons.picture_as_pdf, 'Brochure', AppRoutes.brochure,
              const Color(0xFFDB2777)), // pink
          _item(Icons.currency_rupee, 'Fees', AppRoutes.fees,
              const Color(0xFFD97706)), // amber
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout'),
            onTap: () {
              GetStorage().remove(AppStrings.tokenKey);
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  // route null ho to "Coming soon" dikhayega (jab tak screen nahi bani)
  Widget _item(IconData icon, String title, String? route, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Get.back(); // drawer band
        if (route == null) {
          Get.snackbar(title, 'Coming soon');
        } else if (Get.currentRoute != route) {
          Get.toNamed(route);
        }
      },
    );
  }
}