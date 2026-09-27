import 'package:flutter/material.dart';

import '../../models/registration.dart';
import '../../routes.dart';
import '../../services/file_picker.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Layar unggah dokumen persyaratan pendaftaran (FR-09).
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  Registration? _reg;
  String? _uploadingJenis;

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

  Future<void> _upload(DocumentItem doc) async {
    final fileName = await pickFileName();
    if (!mounted) return;
    if (fileName == null) return;
    final reg = _reg;
    if (reg == null) return;

    setState(() => _uploadingJenis = doc.jenis);
    await Future.delayed(const Duration(milliseconds: 900));
    ServiceLocator.registration.uploadDocument(reg, doc.jenis, fileName);
    if (!mounted) return;
    setState(() => _uploadingJenis = null);
  }

  @override
  Widget build(BuildContext context) {
    final reg = _reg;
    if (reg == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dokumen Persyaratan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _introCard(),
            const SizedBox(height: 12),
            if (reg.dokumenLengkap) ...[
              _successBanner(),
              const SizedBox(height: 12),
            ],
            for (final doc in reg.documents)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _docCard(doc),
              ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, Routes.payment),
              child: const Text('Lanjut ke Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _introCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.upload_file, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Unggah softcopy dokumen persyaratan pendaftaran.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _successBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seluruh dokumen lengkap ✓',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docCard(DocumentItem doc) {
    final isUploading = _uploadingJenis == doc.jenis;
    final uploaded = !doc.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.jenis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        uploaded ? doc.fileName : 'Belum diunggah',
                        style: TextStyle(
                          fontSize: 13,
                          color: uploaded
                              ? AppColors.primaryDark
                              : AppColors.muted,
                        ),
                      ),
                      if (uploaded) ...[
                        const SizedBox(height: 6),
                        _verifiedChip(doc.verified),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: isUploading ? null : () => _upload(doc),
                  child: Text(uploaded ? 'Ganti' : 'Unggah'),
                ),
              ],
            ),
            if (isUploading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  /// Chip kecil status verifikasi dokumen oleh admin.
  Widget _verifiedChip(bool verified) {
    final color = verified ? AppColors.success : AppColors.muted;
    final icon = verified ? Icons.verified : Icons.hourglass_empty;
    final label = verified ? 'Terverifikasi' : 'Menunggu verifikasi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
