import 'package:flutter/material.dart';

import '../../models/contact.dart';
import '../../models/faq.dart';
import '../../models/track.dart';
import '../../routes.dart';
import '../../services/mock_data.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Menampilkan informasi umum Microcredential Polibatam: track & peminatan,
/// rekening pembayaran, FAQ, dan contact person.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Umum')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.route_outlined,
              title: 'Track & Peminatan',
            ),
            for (final track in MockData.tracks) _buildTrackCard(track),
            const SizedBox(height: 8),
            const _SectionHeader(
              icon: Icons.account_balance_outlined,
              title: 'Rekening Pembayaran',
            ),
            _buildRekeningCard(),
            const SizedBox(height: 8),
            const _SectionHeader(
              icon: Icons.help_outline,
              title: 'FAQ',
            ),
            for (final faq in MockData.faqs) _buildFaqCard(faq),
            const SizedBox(height: 8),
            const _SectionHeader(
              icon: Icons.contact_phone_outlined,
              title: 'Contact Person',
            ),
            for (final contact in MockData.contacts) _buildContactCard(contact),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackCard(Track track) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.cast_for_education,
            color: AppColors.primary, size: 26),
        title: Text(
          track.nama,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Text(
          track.deskripsi,
          style: const TextStyle(height: 1.3),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          for (final peminatan in track.peminatanList)
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              leading: const Icon(Icons.school_outlined,
                  color: AppColors.primary, size: 22),
              title: Text(
                peminatan.nama,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${peminatan.biaya} • ${peminatan.durasi}'),
            ),
        ],
      ),
    );
  }

  Widget _buildRekeningCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance, color: AppColors.primary, size: 22),
                SizedBox(width: 8),
                Text(
                  'Detail Rekening',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (MockData.bankName.isNotEmpty)
              _buildLabelValue('Bank', MockData.bankName),
            if (MockData.rekeningNumber.isNotEmpty)
              _buildLabelValue('Nomor Rekening', MockData.rekeningNumber),
            if (MockData.rekeningPemilik.isNotEmpty)
              _buildLabelValue('Atas Nama', MockData.rekeningPemilik),
            if (MockData.biayaPendaftaran.isNotEmpty)
              _buildLabelValue(
                  'Biaya Pendaftaran', MockData.biayaPendaftaran),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildFaqCard(FaqItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: const Icon(Icons.quiz_outlined,
            color: AppColors.primary, size: 24),
        title: Text(
          item.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ContactPerson contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: _ContactAvatar(nama: contact.nama),
        title: Text(
          contact.nama,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(contact.jabatan,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            _ContactDetail(icon: Icons.phone_outlined, text: contact.telepon),
            const SizedBox(height: 2),
            _ContactDetail(icon: Icons.mail_outline, text: contact.email),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

/// Judul bagian dengan ikon untuk halaman informasi.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Avatar lingkaran berisi inisial nama contact person.
class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({required this.nama});

  final String nama;

  @override
  Widget build(BuildContext context) {
    final initial =
        nama.trim().isEmpty ? '?' : nama.trim().substring(0, 1).toUpperCase();
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

/// Baris detail kontak (telepon/email) dengan ikon kecil.
class _ContactDetail extends StatelessWidget {
  const _ContactDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}
