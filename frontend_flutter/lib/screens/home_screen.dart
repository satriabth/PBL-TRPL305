import 'package:flutter/material.dart';

import '../models/registration.dart';
import '../models/user.dart';
import '../routes.dart';
import '../services/service_locator.dart';
import '../theme.dart';

/// Beranda (route '/home'). Menampilkan menu sesuai peran pengguna yang
/// sedang masuk. Jika tidak ada sesi, menampilkan ajakan untuk masuk.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    ServiceLocator.auth.logout();
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (r) => false);
  }

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator.auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beranda')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.login, color: AppColors.muted, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Anda belum masuk',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan masuk untuk melihat menu registrasi.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => _goToLogin(context),
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _buildBody(context, user),
    );
  }

  Widget _buildBody(BuildContext context, User user) {
    final items = _menuItems(context, user);
    final status = ServiceLocator.registration.forMaba(user)?.status;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WelcomeHeaderCard(user: user),
                  if (user.role == UserRole.maba) ...[
                    const SizedBox(height: 16),
                    _StatusSnapshotCard(
                      status: status,
                      onTap: () => Navigator.of(context).pushNamed(Routes.status),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Seksi menu per peran (selain maba sudah ditampilkan di header).
                  if (user.role != UserRole.maba) ...[
                    Text(
                      'Role: ${user.role.label}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 3
                          : (constraints.maxWidth >= 600 ? 2 : 1);
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          for (final item in items) _MenuCard(item: item),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu menu sesuai peran pengguna.
  List<_MenuItem> _menuItems(BuildContext context, User user) {
    return switch (user.role) {
      UserRole.maba => [
          _MenuItem(
            title: 'Formulir Pendaftaran',
            icon: Icons.assignment_outlined,
            color: AppColors.primary,
            onTap: () => Navigator.of(context).pushNamed(Routes.form),
          ),
          _MenuItem(
            title: 'Upload Dokumen',
            icon: Icons.upload_file_outlined,
            color: AppColors.accent,
            onTap: () => Navigator.of(context).pushNamed(Routes.documents),
          ),
          _MenuItem(
            title: 'Pembayaran',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.warning,
            onTap: () => Navigator.of(context).pushNamed(Routes.payment),
          ),
          _MenuItem(
            title: 'Status Registrasi',
            icon: Icons.fact_check_outlined,
            color: AppColors.success,
            onTap: () => Navigator.of(context).pushNamed(Routes.status),
          ),
          _MenuItem(
            title: 'Informasi Umum',
            icon: Icons.info_outline,
            color: AppColors.muted,
            onTap: () => Navigator.of(context).pushNamed(Routes.info),
          ),
        ],
      UserRole.admin => [
          _MenuItem(
            title: 'Verifikasi Pendaftaran (Admin)',
            icon: Icons.verified_user_outlined,
            color: AppColors.primary,
            onTap: () => Navigator.of(context).pushNamed(Routes.admin),
          ),
        ],
      UserRole.keuangan => [
          _MenuItem(
            title: 'Verifikasi Pembayaran',
            icon: Icons.payments_outlined,
            color: AppColors.success,
            onTap: () => Navigator.of(context).pushNamed(Routes.finance),
          ),
        ],
      UserRole.superAdmin => [
          _MenuItem(
            title: 'Kelola Master Data',
            icon: Icons.settings_outlined,
            color: AppColors.accent,
            onTap: () => Navigator.of(context).pushNamed(Routes.masterData),
          ),
          _MenuItem(
            title: 'Informasi Umum',
            icon: Icons.info_outline,
            color: AppColors.muted,
            onTap: () => Navigator.of(context).pushNamed(Routes.info),
          ),
        ],
    };
  }
}

/// Warna status sesuai fase registrasi.
Color _statusColor(RegistrationStatus? status) => switch (status) {
      RegistrationStatus.draft => AppColors.warning,
      RegistrationStatus.submitted => AppColors.accent,
      RegistrationStatus.approvedAdmin ||
      RegistrationStatus.approvedKeuangan =>
        AppColors.primary,
      RegistrationStatus.selesai => AppColors.success,
      RegistrationStatus.rejectedAdmin ||
      RegistrationStatus.rejectedKeuangan =>
        AppColors.danger,
      null => AppColors.muted,
    };

/// Ikon status sesuai fase registrasi.
IconData _statusIcon(RegistrationStatus? status) => switch (status) {
      RegistrationStatus.draft => Icons.edit_note,
      RegistrationStatus.submitted => Icons.hourglass_top,
      RegistrationStatus.approvedAdmin ||
      RegistrationStatus.approvedKeuangan =>
        Icons.verified_outlined,
      RegistrationStatus.selesai => Icons.check_circle_outline,
      RegistrationStatus.rejectedAdmin ||
      RegistrationStatus.rejectedKeuangan =>
        Icons.cancel_outlined,
      null => Icons.inbox_outlined,
    };

/// Kartu sapaan dengan nama, peran, dan identitas aplikasi.
class _WelcomeHeaderCard extends StatelessWidget {
  final User user;

  const _WelcomeHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${user.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Text(
              user.role.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Microcredential Polibatam',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu ringkasan status registrasi untuk calon mahasiswa.
class _StatusSnapshotCard extends StatelessWidget {
  final RegistrationStatus? status;
  final VoidCallback onTap;

  const _StatusSnapshotCard({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final label = status?.label ?? 'Belum ada pendaftaran';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(_statusIcon(status), color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Registrasi',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Lihat Status'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data satu item menu beranda.
class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// Kartu warna menu beranda.
class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.color,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
