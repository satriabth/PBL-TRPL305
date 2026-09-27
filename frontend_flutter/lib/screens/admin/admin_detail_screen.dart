import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../models/registration.dart';
import '../../models/user.dart';
import '../../routes.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Halaman detail pendaftaran untuk verifikasi admin: menampilkan ringkasan
/// data calon mahasiswa, pendidikan, program, dokumen, dan pembayaran,
/// dengan tombol setujui / tolak saat status masih submitted.
class AdminDetailScreen extends StatelessWidget {
  const AdminDetailScreen({super.key});

  Future<void> _showRejectDialog(BuildContext context, Registration r) async {
    final catatan = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _RejectDialog(
        title: 'Tolak Pendaftaran',
        confirmLabel: 'Tolak',
      ),
    );
    if (catatan == null || !context.mounted) return;
    ServiceLocator.registration.rejectByAdmin(r, catatan);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pendaftaran ditolak')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator.auth.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const _AksesDitolakScreen();
    }

    final id = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pendaftaran')),
      body: ListenableBuilder(
        listenable: ServiceLocator.registration,
        builder: (context, _) {
          final r = ServiceLocator.registration.byId(id);
          if (r == null) return const _DataTidakDitemukan();
          return _buildContent(context, r);
        },
      ),
    );
  }

  /// Format tanggal & waktu lokal dd/MM/yyyy HH:mm.
  String _formatDateTime(DateTime? d) {
    if (d == null) return '-';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} $hour:$minute';
  }

  Widget _buildContent(BuildContext context, Registration r) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(title: 'Data Calon Mahasiswa', children: [
            _InfoRow(label: 'Nama', value: r.maba.name),
            _InfoRow(label: 'Email', value: r.maba.email),
            _InfoRow(label: 'NIK', value: r.dataDiri.nik),
            _InfoRow(
              label: 'Tempat, Tgl Lahir',
              value: '${r.dataDiri.tempatLahir}, ${r.dataDiri.tanggalLahir}',
            ),
            _InfoRow(label: 'Jenis Kelamin', value: r.dataDiri.jenisKelamin),
            _InfoRow(label: 'Alamat', value: r.dataDiri.alamat),
            _InfoRow(label: 'Telepon', value: r.dataDiri.telepon),
          ]),
          _SectionCard(title: 'Data Pendidikan', children: [
            _InfoRow(label: 'Asal Sekolah', value: r.dataPendidikan.asalSekolah),
            _InfoRow(label: 'Jurusan', value: r.dataPendidikan.jurusan),
            _InfoRow(label: 'Tahun Lulus', value: r.dataPendidikan.tahunLulus),
            _InfoRow(
              label: 'Rata-rata Nilai',
              value: r.dataPendidikan.rataRataNilai,
            ),
          ]),
          _SectionCard(title: 'Program', children: [
            _InfoRow(label: 'Track', value: r.track?.nama ?? '-'),
            _InfoRow(label: 'Deskripsi', value: r.track?.deskripsi ?? '-'),
            _InfoRow(label: 'Peminatan', value: r.peminatan?.nama ?? '-'),
            _InfoRow(label: 'Biaya', value: r.peminatan?.biaya ?? '-'),
            _InfoRow(label: 'Durasi', value: r.peminatan?.durasi ?? '-'),
          ]),
          _SectionCard(
            title: 'Dokumen',
            children: [
              ...r.documents.map((doc) => _DocumentRow(doc: doc)),
            ],
          ),
          _SectionCard(
            title: 'Pembayaran',
            trailing: _StatusChip(
              label: r.payment.status.label,
              color: _paymentColor(r.payment.status),
            ),
            children: [
              _InfoRow(
                label: 'Bukti Pembayaran',
                value: r.payment.buktiFileName ?? '-',
              ),
              _InfoRow(
                label: 'Diunggah',
                value: _formatDateTime(r.payment.uploadedAt),
              ),
            ],
          ),
          if (r.status == RegistrationStatus.submitted)
            _buildActionBar(context, r)
          else
            _StatusBanner(reg: r),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, Registration r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ServiceLocator.registration.approveByAdmin(r);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disetujui')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Setujui'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () => _showRejectDialog(context, r),
              child: const Text('Tolak'),
            ),
          ),
        ],
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

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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

class _DocumentRow extends StatelessWidget {
  final DocumentItem doc;

  const _DocumentRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    final verified = doc.verified;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              doc.jenis,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.fileName.isEmpty ? '(belum diunggah)' : doc.fileName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (verified ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    verified ? 'Terverifikasi' : 'Perlu dicek',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: verified ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Registration reg;

  const _StatusBanner({required this.reg});

  @override
  Widget build(BuildContext context) {
    final message = _message(reg.status);
    final icon = _icon(reg.status);
    final color = _color(reg.status);
    final note = switch (reg.status) {
      RegistrationStatus.rejectedAdmin => reg.adminNote,
      RegistrationStatus.rejectedKeuangan => reg.financeNote,
      _ => null,
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (note != null && note.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  String _message(RegistrationStatus s) => switch (s) {
        RegistrationStatus.approvedAdmin =>
          'Disetujui admin — menunggu verifikasi keuangan',
        RegistrationStatus.approvedKeuangan =>
          'Disetujui oleh bagian keuangan',
        RegistrationStatus.selesai => 'Registrasi selesai',
        RegistrationStatus.rejectedAdmin =>
          'Ditolak admin — perbaiki sesuai catatan lalu submit ulang',
        RegistrationStatus.rejectedKeuangan =>
          'Pembayaran ditolak keuangan — perbaiki sesuai catatan lalu submit ulang',
        RegistrationStatus.submitted => 'Menunggu verifikasi admin',
        _ => 'Status: ${s.label}',
      };

  IconData _icon(RegistrationStatus s) => switch (s) {
        RegistrationStatus.approvedAdmin ||
        RegistrationStatus.approvedKeuangan ||
        RegistrationStatus.selesai =>
          Icons.verified_outlined,
        RegistrationStatus.rejectedAdmin ||
        RegistrationStatus.rejectedKeuangan =>
          Icons.cancel_outlined,
        _ => Icons.info_outline,
      };

  Color _color(RegistrationStatus s) => switch (s) {
        RegistrationStatus.approvedAdmin ||
        RegistrationStatus.approvedKeuangan ||
        RegistrationStatus.selesai =>
          AppColors.success,
        RegistrationStatus.rejectedAdmin ||
        RegistrationStatus.rejectedKeuangan =>
          AppColors.danger,
        _ => AppColors.primary,
      };
}

class _RejectDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;

  const _RejectDialog({required this.title, required this.confirmLabel});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final catatan = _controller.text.trim();
    if (catatan.isEmpty) {
      setState(() => _errorText = 'Catatan alasan penolakan wajib diisi.');
      return;
    }
    Navigator.of(context).pop(catatan);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        minLines: 2,
        maxLines: 4,
        autofocus: true,
        onChanged: (_) {
          if (_errorText != null) setState(() => _errorText = null);
        },
        decoration: InputDecoration(
          hintText: 'Catatan alasan penolakan…',
          border: const OutlineInputBorder(),
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: _confirm,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _DataTidakDitemukan extends StatelessWidget {
  const _DataTidakDitemukan();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.muted),
            const SizedBox(height: 12),
            const Text(
              'Data tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali'),
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
