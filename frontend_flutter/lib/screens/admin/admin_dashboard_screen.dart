import 'package:flutter/material.dart';

import '../../models/registration.dart';
import '../../models/user.dart';
import '../../routes.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Dasbor verifikasi admin: daftar pendaftaran yang menunggu verifikasi
/// beserta pencarian berdasarkan nama calon mahasiswa.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Format tanggal lokal dd/MM/yyyy.
  String _formatTanggal(DateTime? d) {
    if (d == null) return '-';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator.auth.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const _AksesDitolakScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Admin')),
      body: ListenableBuilder(
        listenable: ServiceLocator.registration,
        builder: (context, _) {
          final pending = ServiceLocator.registration.pendingAdmin;
          final query = _query.trim().toLowerCase();
          final daftar = query.isEmpty
              ? pending
              : pending
                  .where((r) => r.maba.name.toLowerCase().contains(query))
                  .toList();

          // Bedakan kondisi: tidak ada antrean sama sekali vs. hasil pencarian kosong.
          final emptyMessage = _query.trim().isNotEmpty
              ? 'Tidak cocok untuk kata kunci pencarian “$_query”.'
              : 'Belum ada pendaftaran yang menunggu verifikasi.';

          return Column(
            children: [
              _HeaderCard(
                title: 'Menunggu verifikasi: ${pending.length}',
                subtitle: 'Setujui atau tolak pendaftaran pada halaman detail.',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama calon mahasiswa…',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: daftar.isEmpty
                    ? _EmptyState(
                        icon: Icons.inbox_outlined,
                        message: emptyMessage,
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 720;
                          Widget item(int index) {
                            final reg = daftar[index];
                            return _RegistrationCard(
                              reg: reg,
                              formatTanggal: _formatTanggal,
                              onTap: () => Navigator.pushNamed(
                                context,
                                Routes.adminDetail,
                                arguments: reg.id,
                              ),
                            );
                          }

                          if (!wide) {
                            return ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: daftar.length,
                              itemBuilder: (context, index) => item(index),
                            );
                          }
                          return GridView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: daftar.length,
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
  final String Function(DateTime?) formatTanggal;

  const _RegistrationCard({
    required this.reg,
    required this.onTap,
    required this.formatTanggal,
  });

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
          'Email: ${reg.maba.email} • Submitted ${formatTanggal(reg.submittedAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(label: reg.status.label, color: AppColors.primary),
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
