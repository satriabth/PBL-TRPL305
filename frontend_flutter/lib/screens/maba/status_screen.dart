import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../models/registration.dart';
import '../../routes.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';
import '../../widgets/timeline_widget.dart';

/// Menampilkan status registrasi calon mahasiswa beserta ringkasan
/// pembayaran, timeline, dan catatan perbaikan (jika pendaftaran ditolak).
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator.auth.currentUser;
    if (user == null) {
      // Belum login: kembali ke halaman login.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.login,
          (route) => false,
        );
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final registration = ServiceLocator.registration.getOrCreateFor(user);
    final status = registration.status;
    final statusColor = _statusColor(status);

    return Scaffold(
      appBar: AppBar(title: const Text('Status Registrasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(context, status, statusColor),
            const SizedBox(height: 16),
            _buildPaymentCard(context, registration),
            if (registration.payment.status == PaymentStatus.menungguVerifikasi)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: _InfoChip(
                  icon: Icons.hourglass_top,
                  text: 'Pembayaran menunggu verifikasi keuangan',
                  color: AppColors.accent,
                ),
              ),
            if (status == RegistrationStatus.selesai)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: _InfoChip(
                  icon: Icons.celebration,
                  text: 'Selamat! Registrasi Anda dinyatakan SELESAI',
                  color: AppColors.success,
                ),
              ),
            const SizedBox(height: 16),
            _buildTimelineCard(context, registration),
            if (status.isRejected)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildRejectionCard(context, registration),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(RegistrationStatus status) => switch (status) {
        RegistrationStatus.draft => AppColors.muted,
        RegistrationStatus.submitted => AppColors.accent,
        RegistrationStatus.approvedAdmin ||
        RegistrationStatus.approvedKeuangan ||
        RegistrationStatus.selesai =>
          AppColors.success,
        RegistrationStatus.rejectedAdmin ||
        RegistrationStatus.rejectedKeuangan =>
          AppColors.danger,
      };

  IconData _statusIcon(RegistrationStatus status) => switch (status) {
        RegistrationStatus.draft => Icons.edit_note,
        RegistrationStatus.submitted => Icons.send,
        RegistrationStatus.approvedAdmin ||
        RegistrationStatus.approvedKeuangan =>
          Icons.verified_user,
        RegistrationStatus.selesai => Icons.check_circle,
        RegistrationStatus.rejectedAdmin ||
        RegistrationStatus.rejectedKeuangan =>
          Icons.cancel,
      };

  Widget _buildStatusCard(
      BuildContext context, RegistrationStatus status, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
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
                        .bodyMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
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

  // ---------- Ringkasan pembayaran ----------

  Color _paymentColor(PaymentStatus status) => switch (status) {
        PaymentStatus.belumBayar => AppColors.muted,
        PaymentStatus.menungguVerifikasi => AppColors.accent,
        PaymentStatus.disetujui => AppColors.success,
        PaymentStatus.ditolak => AppColors.danger,
      };

  IconData _paymentIcon(PaymentStatus status) => switch (status) {
        PaymentStatus.belumBayar => Icons.account_balance_wallet_outlined,
        PaymentStatus.menungguVerifikasi => Icons.hourglass_top,
        PaymentStatus.disetujui => Icons.check_circle_outline,
        PaymentStatus.ditolak => Icons.cancel_outlined,
      };

  Widget _buildPaymentCard(
      BuildContext context, Registration registration) {
    final payment = registration.payment;
    final color = _paymentColor(payment.status);
    final catatan = payment.catatan?.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembayaran',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Icon(_paymentIcon(payment.status), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Pembayaran',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        payment.status.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (catatan != null && catatan.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.30)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flag_outlined, color: AppColors.danger, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Catatan Keuangan',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  catatan,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const Divider(height: 24),
            if (registration.pembayaranLengkap) ...[
              _buildPaymentDetailRow(
                Icons.cloud_done_outlined,
                'Bukti terunggah: ${payment.buktiFileName}',
              ),
              if (payment.uploadedAt != null)
                _buildPaymentDetailRow(
                  Icons.schedule,
                  'Diunggah: ${_formatTanggal(payment.uploadedAt!)}',
                ),
            ] else
              _buildBelumUnggah(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBelumUnggah() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.upload_file, color: AppColors.warning, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bukti pembayaran belum diunggah. Unggah bukti transfer Anda di menu Pembayaran.',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Timeline & catatan perbaikan ----------

  Widget _buildTimelineCard(
      BuildContext context, Registration registration) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline Pendaftaran',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TimelineWidget(
              steps: ServiceLocator.registration.timelineFor(registration),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionCard(BuildContext context, Registration registration) {
    final adminNote = registration.adminNote;
    final financeNote = registration.financeNote;
    if (adminNote == null && financeNote == null) return const SizedBox.shrink();

    return Card(
      color: AppColors.danger.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: AppColors.danger, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Catatan Perbaikan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (adminNote != null)
              _buildNote(context, 'Catatan Admin:', adminNote, AppColors.danger),
            if (financeNote != null)
              _buildNote(
                  context, 'Catatan Keuangan:', financeNote, AppColors.danger),
          ],
        ),
      ),
    );
  }

  Widget _buildNote(BuildContext context, String prefix, String note, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$prefix $note',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ---------- Utilitas ----------

  String _formatTanggal(DateTime waktu) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year}';
  }
}

/// Bilah informasi ringkas berwarna (digunakan untuk status & banner).
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
