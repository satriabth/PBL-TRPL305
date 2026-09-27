import 'package:flutter/material.dart';

import '../../models/contact.dart';
import '../../models/faq.dart';
import '../../models/track.dart';
import '../../models/user.dart';
import '../../routes.dart';
import '../../services/mock_data.dart';
import '../../services/service_locator.dart';
import '../../theme.dart';

/// Dashboard Super Admin untuk mengelola master data (demo, in-memory):
/// pengguna, track & peminatan, FAQ, rekening pembayaran, dan contact person.
///
/// Data dimulai dari [MockData] lalu dikelola di memori layar ini (tidak
/// menyentuh service/model lain). Hanya dapat diakses oleh pengguna berperan
/// Super Admin; selain itu ditampilkan layar "Akses ditolak".
class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  late List<Track> _tracks;
  late List<FaqItem> _faqs;
  late List<ContactPerson> _contacts;
  late String _bankName;
  late String _rekeningNumber;
  late String _rekeningPemilik;
  late String _biayaPendaftaran;

  @override
  void initState() {
    super.initState();
    // Salinan kerja (demo in-memory) dari data awal MockData.
    _tracks = MockData.tracks
        .map((t) => Track(
              id: t.id,
              nama: t.nama,
              deskripsi: t.deskripsi,
              peminatanList: List<Peminatan>.of(t.peminatanList),
            ))
        .toList();
    _faqs = List<FaqItem>.of(MockData.faqs);
    _contacts = List<ContactPerson>.of(MockData.contacts);
    _bankName = MockData.bankName;
    _rekeningNumber = MockData.rekeningNumber;
    _rekeningPemilik = MockData.rekeningPemilik;
    _biayaPendaftaran = MockData.biayaPendaftaran;
  }

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator.auth.currentUser;
    if (user == null || user.role != UserRole.superAdmin) {
      return _buildAksesDitolak(context);
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(title: const Text('Master Data')),
        body: Column(
          children: [
            Material(
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.primary,
                dividerColor: AppColors.border,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Pengguna'),
                  Tab(text: 'Track & Peminatan'),
                  Tab(text: 'FAQ'),
                  Tab(text: 'Rekening'),
                  Tab(text: 'Kontak'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPenggunaTab(),
                  _buildTrackTab(),
                  _buildFaqTab(),
                  _buildRekeningTab(),
                  _buildKontakTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAksesDitolak(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Data')),
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
                'Halaman ini hanya dapat diakses oleh pengguna dengan peran '
                'Super Admin.',
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

  // ---------- Tab: Pengguna (hanya tampilan) ----------

  Widget _buildPenggunaTab() {
    final accounts = ServiceLocator.auth.accounts;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Daftar akun dikelola oleh layanan autentikasi; '
                  'ditampilkan di sini sebagai referensi (hanya baca).',
                  style: TextStyle(fontSize: 13, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final account in accounts)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  account.name.isEmpty ? '?' : account.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                account.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(account.email),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _roleColor(account.role).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  account.role.label,
                  style: TextStyle(
                    color: _roleColor(account.role),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _roleColor(UserRole role) => switch (role) {
        UserRole.maba => AppColors.accent,
        UserRole.admin => AppColors.primary,
        UserRole.keuangan => AppColors.warning,
        UserRole.superAdmin => AppColors.danger,
      };

  // ---------- Tab: Track & Peminatan ----------

  Widget _buildTrackTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final track in _tracks) _buildTrackCard(track),
      ],
    );
  }

  Widget _buildTrackCard(Track track) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          track.nama,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${track.deskripsi}\n${track.peminatanList.length} peminatan',
          style: const TextStyle(height: 1.3),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final peminatan in track.peminatanList)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school_outlined,
                  color: AppColors.primary, size: 22),
              title: Text(
                peminatan.nama,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${peminatan.biaya} • ${peminatan.durasi}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.danger),
                tooltip: 'Hapus peminatan',
                onPressed: () => _confirmDeletePeminatan(context, track, peminatan),
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _showAddPeminatanDialog(context, track),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Peminatan'),
            ),
          ),
        ],
      ),
    );
  }

  int get _nextPeminatanId {
    var maxId = 1000;
    for (final t in _tracks) {
      for (final p in t.peminatanList) {
        if (p.id > maxId) maxId = p.id;
      }
    }
    return maxId + 1;
  }

  Future<void> _showAddPeminatanDialog(BuildContext context, Track track) async {
    final namaCtrl = TextEditingController();
    final biayaCtrl = TextEditingController();
    final durasiCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Peminatan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nama Peminatan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: biayaCtrl,
                decoration:
                    const InputDecoration(labelText: 'Biaya (Rp2.000.000)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durasiCtrl,
                decoration: const InputDecoration(labelText: 'Durasi (3 bulan)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    final nama = namaCtrl.text.trim();
    if (ok == true && nama.isNotEmpty) {
      final peminatan = Peminatan(
        id: _nextPeminatanId,
        nama: nama,
        deskripsi: '',
        biaya: biayaCtrl.text.trim().isEmpty ? '-' : biayaCtrl.text.trim(),
        durasi: durasiCtrl.text.trim().isEmpty ? '-' : durasiCtrl.text.trim(),
      );
      setState(() {
        final idx = _tracks.indexWhere((t) => t.id == track.id);
        if (idx >= 0) {
          final t = _tracks[idx];
          _tracks[idx] = Track(
            id: t.id,
            nama: t.nama,
            deskripsi: t.deskripsi,
            peminatanList: [...t.peminatanList, peminatan],
          );
        }
      });
      _showSnack('Peminatan ditambahkan ke "${track.nama}".');
    } else if (ok == true) {
      _showSnack('Nama peminatan tidak boleh kosong.');
    }
    namaCtrl.dispose();
    biayaCtrl.dispose();
    durasiCtrl.dispose();
  }

  Future<void> _confirmDeletePeminatan(
      BuildContext context, Track track, Peminatan peminatan) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Peminatan?'),
        content: Text(
          'Yakin ingin menghapus "${peminatan.nama}" dari track '
          '"${track.nama}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!context.mounted || ok != true) return;
    setState(() {
      final idx = _tracks.indexWhere((t) => t.id == track.id);
      if (idx >= 0) {
        final t = _tracks[idx];
        _tracks[idx] = Track(
          id: t.id,
          nama: t.nama,
          deskripsi: t.deskripsi,
          peminatanList:
              t.peminatanList.where((p) => p.id != peminatan.id).toList(),
        );
      }
    });
    _showSnack('Peminatan "${peminatan.nama}" dihapus.');
  }

  // ---------- Tab: FAQ ----------

  Widget _buildFaqTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTambahButton(
          label: 'Tambah FAQ',
          onPressed: () => _showFaqDialog(),
        ),
        for (var i = 0; i < _faqs.length; i++) _buildFaqCard(i),
      ],
    );
  }

  Widget _buildFaqCard(int index) {
    final faq = _faqs[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading:
            const Icon(Icons.quiz_outlined, color: AppColors.primary, size: 24),
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          faq.answer,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(height: 1.3),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              tooltip: 'Edit FAQ',
              onPressed: () => _showFaqDialog(existing: faq, index: index),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              tooltip: 'Hapus FAQ',
              onPressed: () => _confirmDeleteFaq(index),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFaqDialog({FaqItem? existing, int? index}) async {
    final isEdit = existing != null;
    final questionCtrl = TextEditingController(text: existing?.question ?? '');
    final answerCtrl = TextEditingController(text: existing?.answer ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Edit FAQ' : 'Tambah FAQ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Pertanyaan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: answerCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Jawaban'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    final question = questionCtrl.text.trim();
    final answer = answerCtrl.text.trim();
    if (ok == true && question.isNotEmpty && answer.isNotEmpty) {
      setState(() {
        final item = FaqItem(question: question, answer: answer);
        if (isEdit && index != null) {
          _faqs[index] = item;
        } else {
          _faqs.add(item);
        }
      });
      _showSnack(isEdit ? 'FAQ diperbarui.' : 'FAQ ditambahkan.');
    } else if (ok == true) {
      _showSnack('Pertanyaan dan jawaban wajib diisi.');
    }
    questionCtrl.dispose();
    answerCtrl.dispose();
  }

  Future<void> _confirmDeleteFaq(int index) async {
    final faq = _faqs[index];
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus FAQ?'),
        content: Text('Yakin ingin menghapus FAQ "${faq.question}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!context.mounted || ok != true) return;
    setState(() => _faqs.removeAt(index));
    _showSnack('FAQ dihapus.');
  }

  // ---------- Tab: Rekening ----------

  Widget _buildRekeningTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelValue('Bank', _bankName),
                _labelValue('Nomor Rekening', _rekeningNumber),
                _labelValue('Atas Nama', _rekeningPemilik),
                _labelValue('Biaya Pendaftaran', _biayaPendaftaran),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTambahButton(
          label: 'Edit Rekening',
          onPressed: () => _showRekeningDialog(),
        ),
      ],
    );
  }

  Widget _labelValue(String label, String value) {
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

  Future<void> _showRekeningDialog() async {
    final bankCtrl = TextEditingController(text: _bankName);
    final nomorCtrl = TextEditingController(text: _rekeningNumber);
    final pemilikCtrl = TextEditingController(text: _rekeningPemilik);
    final biayaCtrl = TextEditingController(text: _biayaPendaftaran);

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Rekening'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankCtrl,
                decoration: const InputDecoration(labelText: 'Bank'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nomorCtrl,
                decoration: const InputDecoration(labelText: 'Nomor Rekening'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pemilikCtrl,
                decoration: const InputDecoration(labelText: 'Atas Nama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: biayaCtrl,
                decoration:
                    const InputDecoration(labelText: 'Biaya Pendaftaran'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (ok == true) {
      setState(() {
        _bankName = bankCtrl.text.trim().isEmpty
            ? _bankName
            : bankCtrl.text.trim();
        _rekeningNumber = nomorCtrl.text.trim().isEmpty
            ? _rekeningNumber
            : nomorCtrl.text.trim();
        _rekeningPemilik = pemilikCtrl.text.trim().isEmpty
            ? _rekeningPemilik
            : pemilikCtrl.text.trim();
        _biayaPendaftaran = biayaCtrl.text.trim().isEmpty
            ? _biayaPendaftaran
            : biayaCtrl.text.trim();
      });
      _showSnack('Rekening diperbarui.');
    }
    bankCtrl.dispose();
    nomorCtrl.dispose();
    pemilikCtrl.dispose();
    biayaCtrl.dispose();
  }

  // ---------- Tab: Kontak ----------

  Widget _buildKontakTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTambahButton(
          label: 'Tambah Kontak',
          onPressed: () => _showContactDialog(),
        ),
        for (var i = 0; i < _contacts.length; i++) _buildContactCard(i),
      ],
    );
  }

  Widget _buildContactCard(int index) {
    final contact = _contacts[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            contact.nama.isEmpty ? '?' : contact.nama[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          contact.nama,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${contact.jabatan}\n${contact.telepon} • ${contact.email}',
          style: const TextStyle(height: 1.3),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          tooltip: 'Hapus kontak',
          onPressed: () => _confirmDeleteContact(index),
        ),
      ),
    );
  }

  Future<void> _showContactDialog() async {
    final namaCtrl = TextEditingController();
    final jabatanCtrl = TextEditingController();
    final teleponCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Kontak'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jabatanCtrl,
                decoration: const InputDecoration(labelText: 'Jabatan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teleponCtrl,
                decoration: const InputDecoration(labelText: 'Telepon'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    final nama = namaCtrl.text.trim();
    final jabatan = jabatanCtrl.text.trim();
    final telepon = teleponCtrl.text.trim();
    final email = emailCtrl.text.trim();
    if (ok == true && nama.isNotEmpty && email.isNotEmpty) {
      setState(() {
        _contacts.add(ContactPerson(
          nama: nama,
          jabatan: jabatan.isEmpty ? '-' : jabatan,
          telepon: telepon.isEmpty ? '-' : telepon,
          email: email,
        ));
      });
      _showSnack('Kontak ditambahkan.');
    } else if (ok == true) {
      _showSnack('Nama dan email wajib diisi.');
    }
    namaCtrl.dispose();
    jabatanCtrl.dispose();
    teleponCtrl.dispose();
    emailCtrl.dispose();
  }

  Future<void> _confirmDeleteContact(int index) async {
    final contact = _contacts[index];
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Kontak?'),
        content: Text('Yakin ingin menghapus kontak "${contact.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!context.mounted || ok != true) return;
    setState(() => _contacts.removeAt(index));
    _showSnack('Kontak dihapus.');
  }

  // ---------- Utilitas UI ----------

  Widget _buildTambahButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: Text(label),
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
