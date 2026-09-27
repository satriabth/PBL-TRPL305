import 'package:flutter/material.dart';

import '../../models/registration.dart';
import '../../routes.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Layar telaah akhir & kirim pendaftaran (FR-10).
class SubmitReviewScreen extends StatefulWidget {
  const SubmitReviewScreen({super.key});

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  Registration? _reg;

  @override
  void initState() {
    super.initState();
    final user = ServiceLocator.auth.currentUser;
    if (user == null) {
      _redirectLogin();
      return;
    }
    _reg = ServiceLocator.registration.getOrCreateFor(user);
  }

  void _redirectLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
    });
  }

  Future<void> _kirim() async {
    final user = ServiceLocator.auth.currentUser;
    if (user == null) return;
    final r = ServiceLocator.registration.getOrCreateFor(user);
    final err = ServiceLocator.registration.submit(r);
    if (!mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pendaftaran terkirim')),
    );
    Navigator.pushNamedAndRemoveUntil(context, Routes.status, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final reg = _reg;
    if (reg == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kirim Pendaftaran')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _progressSummary(reg),
            const SizedBox(height: 16),
            _checklistCard(
              done: reg.dataLengkap,
              title: 'Formulir Lengkap',
              detail: reg.dataLengkap
                  ? '${reg.dataDiri.nama} • ${reg.track?.nama ?? '-'} / '
                      '${reg.peminatan?.nama ?? '-'}'
                  : 'Lengkapi data diri, data pendidikan, dan pilih peminatan.',
            ),
            const SizedBox(height: 12),
            _checklistCard(
              done: reg.dokumenLengkap,
              title: 'Dokumen Lengkap',
              detail: reg.dokumenLengkap
                  ? 'Seluruh ${reg.documents.length} dokumen persyaratan terunggah.'
                  : 'Masih ada dokumen persyaratan yang belum diunggah.',
            ),
            const SizedBox(height: 12),
            _checklistCard(
              done: reg.pembayaranLengkap,
              title: 'Bukti Pembayaran',
              detail: reg.pembayaranLengkap
                  ? 'Bukti transfer telah terunggah.'
                  : 'Unggah bukti transfer pembayaran terlebih dahulu.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: reg.siapSubmit ? _kirim : null,
              child: const Text('Kirim Pendaftaran'),
            ),
            const SizedBox(height: 12),
            Text(
              'Setelah dikirim, data akan terkunci dan masuk ke antrean '
              'verifikasi admin serta keuangan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ringkasan warna-warni kelengkapan pendaftaran sebelum dikirim.
  Widget _progressSummary(Registration reg) {
    final ok = reg.siapSubmit;
    final color = ok ? AppColors.success : AppColors.warning;
    final icon = ok ? Icons.check_circle : Icons.info_outline;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ok ? 'Siap kirim' : 'Belum siap dikirim',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ok
                      ? 'Seluruh prasyarat pendaftaran telah terpenuhi.'
                      : 'Lengkapi formulir, dokumen, dan bukti pembayaran untuk mengirim.',
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistCard({
    required bool done,
    required String title,
    required String detail,
  }) {
    final color = done ? AppColors.success : AppColors.warning;
    final icon = done ? Icons.check_circle : Icons.pending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
