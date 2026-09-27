import 'package:flutter/material.dart';

import '../../models/registration.dart';
import '../../routes.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Ringkasan pendaftaran mahasiswa: kartu identitas + daftar langkah
/// pendaftaran yang bisa dikunjungi (formulir, dokumen, pembayaran, kirim).
class EnrollmentOverviewScreen extends StatefulWidget {
  const EnrollmentOverviewScreen({super.key});

  @override
  State<EnrollmentOverviewScreen> createState() =>
      _EnrollmentOverviewScreenState();
}

/// Warna badge status registrasi.
Color _statusColor(RegistrationStatus status) => switch (status) {
      RegistrationStatus.draft => AppColors.warning,
      RegistrationStatus.submitted => AppColors.accent,
      RegistrationStatus.approvedAdmin => AppColors.accent,
      RegistrationStatus.approvedKeuangan => AppColors.success,
      RegistrationStatus.selesai => AppColors.success,
      RegistrationStatus.rejectedAdmin => AppColors.danger,
      RegistrationStatus.rejectedKeuangan => AppColors.danger,
    };

class _EnrollmentOverviewScreenState extends State<EnrollmentOverviewScreen> {
  Registration? _registration;

  @override
  void initState() {
    super.initState();
    ServiceLocator.registration.addListener(_onChanged);
    final user = ServiceLocator.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin());
      return;
    }
    _registration = ServiceLocator.registration.getOrCreateFor(user);
  }

  @override
  void dispose() {
    ServiceLocator.registration.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _redirectToLogin() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan masuk terlebih dahulu.')),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }

  void _openRoute(String route) {
    if (ServiceLocator.auth.currentUser == null) {
      _redirectToLogin();
      return;
    }
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final registration = _registration;
    if (registration == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final user = ServiceLocator.auth.currentUser;
    final hasDraft =
        user != null && ServiceLocator.registration.loadDraft(user) != null;
    final uploadedCount =
        registration.documents.where((d) => !d.isEmpty).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Pendaftaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hasDraft) ...[
            const _DraftBanner(),
            const SizedBox(height: 16),
          ],
          _HeaderCard(registration: registration),
          const SizedBox(height: 24),
          Text(
            'Langkah Pendaftaran',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _StepCard(
            icon: Icons.edit_note,
            title: 'Formulir Pendaftaran',
            subtitle:
                registration.dataLengkap ? 'Terisi lengkap' : 'Belum lengkap',
            color:
                registration.dataLengkap ? AppColors.success : AppColors.primary,
            onTap: () => _openRoute(Routes.form),
          ),
          _StepCard(
            icon: Icons.upload_file,
            title: 'Upload Dokumen',
            subtitle: registration.dokumenLengkap
                ? 'Lengkap'
                : '$uploadedCount/4 terunggah',
            color: registration.dokumenLengkap
                ? AppColors.success
                : AppColors.primary,
            onTap: () => _openRoute(Routes.documents),
          ),
          _StepCard(
            icon: Icons.payments_outlined,
            title: 'Pembayaran',
            subtitle: registration.payment.buktiFileName != null
                ? 'Bukti terunggah'
                : 'Belum bayar',
            color: registration.pembayaranLengkap
                ? AppColors.success
                : AppColors.primary,
            onTap: () => _openRoute(Routes.payment),
          ),
          _StepCard(
            icon: Icons.send_outlined,
            title: 'Kirim Pendaftaran',
            subtitle:
                registration.siapSubmit ? 'Siap kirim' : 'Lengkapi prasyarat',
            color:
                registration.siapSubmit ? AppColors.success : AppColors.primary,
            onTap: () => _openRoute(Routes.submit),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildCta(registration),
        ),
      ),
    );
  }

  /// Tombol aksi utama bawah sesuai fase pendaftaran.
  Widget _buildCta(Registration registration) {
    // Sudah dikirim / diproses: arahkan ke halaman status.
    if (registration.status != RegistrationStatus.draft) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pendaftaran telah dikirim — pantau perkembangan lewat halaman status.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.muted.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => _openRoute(Routes.status),
            child: const Text('Lihat Status'),
          ),
        ],
      );
    }

    // Draft lengkap: siap dikirim.
    if (registration.siapSubmit) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.rocket_launch_outlined, color: AppColors.warning),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Siap dikirim — seluruh data telah lengkap',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => _openRoute(Routes.submit),
            child: const Text('Kirim Pendaftaran'),
          ),
        ],
      );
    }

    return FilledButton(
      onPressed: () => _openRoute(Routes.form),
      child: const Text('Lanjutkan ke Formulir'),
    );
  }
}

/// Banner khusus yang muncul bila terdapat draft tersimpan untuk mahasiswa ini.
class _DraftBanner extends StatelessWidget {
  const _DraftBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.save_outlined, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Draft tersimpan — lanjutkan dari penyimpanan',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu header: nama mahasiswa dan badge status registrasi.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.registration});

  final Registration registration;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
              child: const Icon(Icons.person, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang,',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    registration.maba.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: registration.status),
          ],
        ),
      ),
    );
  }
}

/// Badge kecil berisi label status dengan warna sesuai fase.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RegistrationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Kartu langkah pendaftaran yang dapat diketuk untuk berpindah halaman.
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
