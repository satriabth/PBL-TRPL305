import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../models/registration.dart';
import '../../models/user.dart';
import '../../routes.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Dasbor verifikasi keuangan: daftar pendaftaran yang menunggu verifikasi
/// pembayaran setelah disetujui admin.
class FinanceDashboardScreen extends StatelessWidget {
  const FinanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator.auth.currentUser;
    if (user == null || user.role != UserRole.keuangan) {
      return const _AksesDitolakScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Keuangan')),
      body: ListenableBuilder(
        listenable: ServiceLocator.registration,
        builder: (context, _) {
          final pending = ServiceLocator.registration.pendingFinance;
          return Column(
            children: [
              _HeaderCard(
                title: 'Menunggu verifikasi keuangan: ${pending.length}',
                subtitle: 'Verifikasi bukti pembayaran pada halaman detail.',
              ),
              Expanded(
                child: pending.isEmpty
                    ? const _EmptyState(
                        icon: Icons.inbox_outlined,
                        message: 'Belum ada pembayaran yang menunggu verifikasi.',
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 720;
                          Widget item(int index) {
                            final reg = pending[index];
                            return _RegistrationCard(
                              reg: reg,
                              onTap: () => Navigator.pushNamed(
                                context,
                                Routes.financeDetail,
                                arguments: reg.id,
                              ),
                            );
                          }

                          if (!wide) {
                            return ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: pending.length,
                              itemBuilder: (context, index) => item(index),
                            );
                          }
                          return GridView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: pending.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 420,
                              mainAxisExtent: 140,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (context, index) => item(index),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Color _paymentColor(PaymentStatus status) => switch (status) {
      PaymentStatus.belumBayar => AppColors.muted,
      PaymentStatus.menungguVerifikasi => AppColors.warning,
      PaymentStatus.disetujui => AppColors.success,
      PaymentStatus.ditolak => AppColors.danger,
    };

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final Registration reg;
  final VoidCallback onTap;

  const _RegistrationCard({required this.reg, required this.onTap});

  String get _initials {
    final parts = reg.maba.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
          return Card(
            margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          foregroundColor: AppColors.primary,
          child: Text(
            _initials,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        title: Text(
          reg.maba.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          'Email: ${reg.maba.email} • ${reg.peminatan?.nama ?? '-'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(label: 'Disetujui Admin', color: AppColors.primary),
            _StatusChip(
              label: reg.payment.status.label,
              color: _paymentColor(reg.payment.status),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _AksesDitolakScreen extends StatelessWidget {
  const _AksesDitolakScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akses Terbatas')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 12),
              const Text(
                'Akses ditolak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda tidak memiliki akses ke halaman ini. Silakan masuk '
                'menggunakan akun dengan peran yang sesuai.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.home, (route) => false),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
