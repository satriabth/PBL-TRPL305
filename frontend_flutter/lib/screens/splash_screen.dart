import 'package:flutter/material.dart';

import '../models/user.dart';
import '../routes.dart';
import '../services/service_locator.dart';
import '../theme.dart';

/// Layar pembuka (route '/'). Menampilkan logo & nama aplikasi, lalu
/// mengarahkan ke login (belum masuk) atau ke beranda sesuai peran.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startNavigation();
  }

  Future<void> _startNavigation() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final auth = ServiceLocator.auth;
    final route = auth.isLoggedIn
        ? _roleRoute(auth.currentUser!.role)
        : Routes.login;
    Navigator.of(context).pushReplacementNamed(route);
  }

  /// Rute beranda sesuai peran pengguna.
  String _roleRoute(UserRole role) => switch (role) {
        UserRole.maba => Routes.home,
        UserRole.admin => Routes.admin,
        UserRole.keuangan => Routes.finance,
        UserRole.superAdmin => Routes.home,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Latar gradasi navy yang konsisten dengan identitas aplikasi.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Logo mark membulat dengan bingkai putih.
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, color: Colors.white, size: 38),
                    SizedBox(height: 4),
                    Text(
                      'MC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Microcredential Polibatam',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Registrasi Mahasiswa Baru',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Spacer(flex: 4),
              // Indikator progres halus di bagian bawah.
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
