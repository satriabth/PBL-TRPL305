import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_detail_screen.dart';
import 'screens/finance/finance_dashboard_screen.dart';
import 'screens/finance/finance_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/maba/documents_screen.dart';
import 'screens/maba/enrollment_overview_screen.dart';
import 'screens/maba/form/multi_step_form_screen.dart';
import 'screens/maba/info_screen.dart';
import 'screens/maba/payment_screen.dart';
import 'screens/maba/status_screen.dart';
import 'screens/maba/submit_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/superadmin/master_data_screen.dart';
import 'services/service_locator.dart';
import 'theme.dart';
import 'widgets/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.init();
  runApp(const MicrocredentialApp());
}

/// Aplikasi Registrasi Microcredential Polibatam.
class MicrocredentialApp extends StatelessWidget {
  const MicrocredentialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microcredential Polibatam — Registrasi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: Routes.splash,
      builder: (context, child) =>
          AppShell(child: child ?? const SizedBox.shrink()),
      routes: {
        Routes.splash: (_) => const SplashScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.register: (_) => const RegisterScreen(),
        Routes.home: (_) => const HomeScreen(),
        Routes.enrollment: (_) => const EnrollmentOverviewScreen(),
        Routes.form: (_) => const MultiStepFormScreen(),
        Routes.documents: (_) => const DocumentsScreen(),
        Routes.payment: (_) => const PaymentScreen(),
        Routes.submit: (_) => const SubmitReviewScreen(),
        Routes.status: (_) => const StatusScreen(),
        Routes.info: (_) => const InfoScreen(),
        Routes.admin: (_) => const AdminDashboardScreen(),
        Routes.adminDetail: (_) => const AdminDetailScreen(),
        Routes.finance: (_) => const FinanceDashboardScreen(),
        Routes.financeDetail: (_) => const FinanceDetailScreen(),
        Routes.masterData: (_) => const SuperAdminDashboardScreen(),
      },
    );
  }
}
