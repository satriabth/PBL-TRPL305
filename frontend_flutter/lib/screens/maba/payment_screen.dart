import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../models/registration.dart';
import '../../routes.dart';
import '../../services/file_picker.dart';
import '../../services/mock_data.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Layar pembayaran biaya pendaftaran awal (FR-11).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Registration? _reg;
  bool _uploading = false;

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

  Future<void> _uploadBukti() async {
    final fileName = await pickFileName();
    if (!mounted) return;
    if (fileName == null) return;
    final reg = _reg;
    if (reg == null) return;

    setState(() => _uploading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    ServiceLocator.registration.uploadBuktiBayar(reg, fileName);
    if (!mounted) return;
    setState(() => _uploading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bukti pembayaran terunggah')),
    );
  }

  Color _statusColor(PaymentStatus status) => switch (status) {
        PaymentStatus.belumBayar => AppColors.muted,
        PaymentStatus.menungguVerifikasi => AppColors.warning,
        PaymentStatus.disetujui => AppColors.success,
        PaymentStatus.ditolak => AppColors.danger,
      };

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final reg = _reg;
    if (reg == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final payment = reg.payment;
    final buktiAda = payment.buktiFileName != null &&
        payment.buktiFileName!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _bankCard(),
            const SizedBox(height: 16),
            Text(
              'Lakukan transfer ke rekening di atas, lalu unggah bukti transfer '
              'untuk verifikasi pembayaran.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            _statusBadge(payment.status),
            if (payment.status == PaymentStatus.ditolak &&
                payment.catatan != null) ...[
              const SizedBox(height: 12),
              _catatanDitolakCard(payment.catatan!),
            ],
            const SizedBox(height: 16),
            if (buktiAda)
              _buktiTerunggahCard(payment)
            else
              _uploadButton(),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: buktiAda
                  ? () => Navigator.pushNamed(context, Routes.submit)
                  : null,
              child: const Text('Lanjut ke Review & Kirim'),
            ),
            if (!buktiAda) ...[
              const SizedBox(height: 8),
              Text(
                'Unggah bukti transfer untuk melanjutkan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bankCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.account_balance, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              MockData.bankName,
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              MockData.rekeningNumber,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              MockData.rekeningPemilik,
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const Divider(height: 24),
            const Text(
              'Biaya Pendaftaran Awal:',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              MockData.biayaPendaftaran,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(PaymentStatus status) {
    final color = _statusColor(status);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_outlined, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                status.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _uploadButton() {
    return FilledButton.icon(
      onPressed: _uploading ? null : _uploadBukti,
      icon: const Icon(Icons.upload_file),
      label: const Text('Unggah Bukti Transfer'),
    );
  }

  /// Catatan penolakan dari bagian keuangan agar mahasiswa tahu alasannya.
  Widget _catatanDitolakCard(String catatan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Catatan keuangan: $catatan',
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buktiTerunggahCard(Payment payment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Text(
                  'Bukti Transfer Terunggah',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              payment.buktiFileName ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Diunggah pada ${_formatDateTime(payment.uploadedAt ?? DateTime.now())}',
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
}
