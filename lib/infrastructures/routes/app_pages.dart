import 'package:get/get.dart';
import 'package:muit_sales_app/infrastructures/routes/app_routes.dart';
import '../../bindings/brochure_binding.dart';
import '../../bindings/crm_binding.dart';
import '../../bindings/dashboard_binding.dart';
import '../../bindings/excel_upload_binding.dart';
import '../../bindings/fees_binding.dart';
import '../../bindings/leads_binding.dart';
import '../../bindings/login_binding.dart';
import '../../bindings/splash_binding.dart';
import '../../bindings/visit_entry_binding.dart';
import '../../screens/brochure_view.dart';
import '../../screens/crm_view.dart';
import '../../screens/dashboard_view.dart';
import '../../screens/excel_upload_view.dart';
import '../../screens/fees_view.dart';
import '../../screens/leads_view.dart';
import '../../screens/login_view.dart';
import '../../screens/splash_view.dart';
import '../../screens/visit_entry_view.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () =>  SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () =>  LoginView(),
      transition: Transition.rightToLeft,
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardView(),
      transition: Transition.rightToLeft,
      binding: DashboardBinding(),
    ),

    GetPage(
      name: AppRoutes.visitEntry,
      page: () =>  VisitEntryView(),
      transition: Transition.rightToLeft,
      binding: VisitEntryBinding(),
    ),

    GetPage(
      name: AppRoutes.leads,
      page: () => LeadsView(),
      transition: Transition.rightToLeft,
      binding: LeadsBinding(),
    ),

    GetPage(
      name: AppRoutes.crm,
      page: () =>  CrmView(),
      transition: Transition.rightToLeft,
      binding: CrmBinding(),
    ),

    GetPage(
      name: AppRoutes.excelUpload,
      page: () => ExcelUploadView(),
      transition: Transition.rightToLeft,
      binding: ExcelUploadBinding(),
    ),
    GetPage(
      name: AppRoutes.brochure,
      page: () =>  BrochureView(),
      transition: Transition.rightToLeft,
      binding: BrochureBinding(),
    ),
    GetPage(
      name: AppRoutes.fees,
      page: () => FeesView(),
      transition: Transition.rightToLeft,
      binding: FeesBinding(),
    ),
  ];
}