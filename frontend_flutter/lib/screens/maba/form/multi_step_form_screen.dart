import 'package:flutter/material.dart';

import '../../../models/registration.dart';
import '../../../models/track.dart';
import '../../../routes.dart';
import '../../../services/mock_data.dart';
import '../../../services/service_locator.dart';
import '../../../theme.dart';

/// Formulir pendaftaran multi-step: Data Diri, Data Pendidikan, dan
/// Track & Peminatan, dengan dukungan penyimpanan draft.
class MultiStepFormScreen extends StatefulWidget {
  const MultiStepFormScreen({super.key});

  @override
  State<MultiStepFormScreen> createState() => _MultiStepFormScreenState();
}

class _MultiStepFormScreenState extends State<MultiStepFormScreen> {
  late Registration _registration;
  int _currentStep = 0;
  bool _ready = false;

  final _formDiriKey = GlobalKey<FormState>();
  final _formPendidikanKey = GlobalKey<FormState>();
  final _formTrackKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _nikController;
  late final TextEditingController _tempatLahirController;
  late final TextEditingController _tanggalLahirController;
  late final TextEditingController _alamatController;
  late final TextEditingController _teleponController;
  late final TextEditingController _emailController;
  late final TextEditingController _asalSekolahController;
  late final TextEditingController _jurusanController;
  late final TextEditingController _tahunLulusController;
  late final TextEditingController _rataRataNilaiController;

  String? _jenisKelamin;
  Track? _selectedTrack;
  Peminatan? _selectedPeminatan;

  @override
  void initState() {
    super.initState();
    final user = ServiceLocator.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin());
      return;
    }
    _registration = ServiceLocator.registration.getOrCreateFor(user);

    final diri = _registration.dataDiri;
    _namaController = TextEditingController(text: diri.nama);
    _nikController = TextEditingController(text: diri.nik);
    _tempatLahirController = TextEditingController(text: diri.tempatLahir);
    _tanggalLahirController = TextEditingController(text: diri.tanggalLahir);
    _jenisKelamin = diri.jenisKelamin.isEmpty ? null : diri.jenisKelamin;
    _alamatController = TextEditingController(text: diri.alamat);
    _teleponController = TextEditingController(text: diri.telepon);
    _emailController = TextEditingController(text: diri.email);

    final pendidikan = _registration.dataPendidikan;
    _asalSekolahController = TextEditingController(text: pendidikan.asalSekolah);
    _jurusanController = TextEditingController(text: pendidikan.jurusan);
    _tahunLulusController = TextEditingController(text: pendidikan.tahunLulus);
    _rataRataNilaiController =
        TextEditingController(text: pendidikan.rataRataNilai);

    _selectedTrack = _registration.track;
    _selectedPeminatan = _registration.peminatan;
    _ready = true;
  }

  @override
  void dispose() {
    if (_ready) {
      _namaController.dispose();
      _nikController.dispose();
      _tempatLahirController.dispose();
      _tanggalLahirController.dispose();
      _alamatController.dispose();
      _teleponController.dispose();
      _emailController.dispose();
      _asalSekolahController.dispose();
      _jurusanController.dispose();
      _tahunLulusController.dispose();
      _rataRataNilaiController.dispose();
    }
    super.dispose();
  }

  void _redirectToLogin() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan masuk terlebih dahulu.')),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }

  // ---------- Validasi ----------

  FormFieldValidator<String> requiredField(String label) => (value) =>
      (value == null || value.trim().isEmpty) ? '$label wajib diisi' : null;

  String? _validateNama(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nama lengkap wajib diisi';
    if (v.length < 3) return 'Nama lengkap minimal 3 karakter';
    return null;
  }

  String? _validateNik(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'NIK wajib diisi';
    if (!RegExp(r'^[0-9]{16}$').hasMatch(v)) {
      return 'NIK harus terdiri dari 16 digit angka';
    }
    return null;
  }

  String? _validateTelepon(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'No. telepon wajib diisi';
    if (!RegExp(r'^\+?[0-9][0-9\s\-]{8,}$').hasMatch(v)) {
      return 'No. telepon minimal 9 digit angka';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validateTahunLulus(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Tahun lulus wajib diisi';
    if (!RegExp(r'^[0-9]{4}$').hasMatch(v)) {
      return 'Tahun lulus harus 4 digit angka';
    }
    final tahun = int.tryParse(v);
    if (tahun == null || tahun < 2019 || tahun > 2026) {
      return 'Tahun lulus harus antara 2019–2026';
    }
    return null;
  }

  String? _validateRataRata(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Rata-rata nilai wajib diisi';
    final angka = double.tryParse(v.replaceAll(',', '.'));
    if (angka == null || angka < 0 || angka > 100) {
      return 'Rata-rata nilai harus angka 0–100';
    }
    return null;
  }

  bool _validateStep(int step) {
    final form = switch (step) {
      0 => _formDiriKey,
      1 => _formPendidikanKey,
      _ => _formTrackKey,
    };
    return form.currentState?.validate() ?? false;
  }

  // ---------- Navigasi step ----------

  void _next() {
    if (!_validateStep(_currentStep)) return;
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  StepState _stepState(int index) {
    if (_currentStep > index) return StepState.complete;
    if (_currentStep == index) return StepState.editing;
    return StepState.indexed;
  }

  // ---------- Pembentukan data & penyimpanan ----------

  DataDiri _buildDataDiri() => DataDiri(
        nama: _namaController.text.trim(),
        nik: _nikController.text.trim(),
        tempatLahir: _tempatLahirController.text.trim(),
        tanggalLahir: _tanggalLahirController.text.trim(),
        jenisKelamin: _jenisKelamin ?? '',
        alamat: _alamatController.text.trim(),
        telepon: _teleponController.text.trim(),
        email: _emailController.text.trim(),
      );

  DataPendidikan _buildDataPendidikan() => DataPendidikan(
        asalSekolah: _asalSekolahController.text.trim(),
        jurusan: _jurusanController.text.trim(),
        tahunLulus: _tahunLulusController.text.trim(),
        rataRataNilai: _rataRataNilaiController.text.trim(),
      );

  void _simpanKeRegistrasi() {
    final service = ServiceLocator.registration;
    service.updateDataDiri(_registration, _buildDataDiri());
    service.updateDataPendidikan(_registration, _buildDataPendidikan());
    final track = _selectedTrack;
    final peminatan = _selectedPeminatan;
    if (track != null && peminatan != null) {
      service.selectTrackPeminatan(_registration, track, peminatan);
    }
  }

  void _simpanDraft() {
    _simpanKeRegistrasi();
    ServiceLocator.registration.saveDraft(_registration);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft berhasil disimpan')),
    );
  }

  void _simpanDanLanjut() {
    var firstInvalid = -1;
    if (!_validateStep(0)) {
      firstInvalid = 0;
    } else if (!_validateStep(1)) {
      firstInvalid = 1;
    } else if (!_validateStep(2) || _selectedPeminatan == null) {
      firstInvalid = 2;
    }

    if (firstInvalid != -1) {
      final namaStep = switch (firstInvalid) {
        0 => 'Data Diri',
        1 => 'Data Pendidikan',
        _ => 'Track & Peminatan',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi bagian $namaStep terlebih dahulu.')),
      );
      setState(() => _currentStep = firstInvalid);
      return;
    }

    _simpanKeRegistrasi();
    ServiceLocator.registration.saveDraft(_registration);
    Navigator.of(context).pushReplacementNamed(Routes.documents);
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Formulir Pendaftaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: (index) => setState(() => _currentStep = index),
          onStepContinue: _next,
          onStepCancel: _back,
          controlsBuilder: (context, details) => _buildControls(),
          steps: [
            Step(
              title: const Text('Data Diri'),
              subtitle: const Text('Identitas dan kontak calon mahasiswa'),
              isActive: _currentStep >= 0,
              state: _stepState(0),
              content: _buildDataDiriStep(),
            ),
            Step(
              title: const Text('Data Pendidikan'),
              subtitle: const Text('Riwayat pendidikan terakhir'),
              isActive: _currentStep >= 1,
              state: _stepState(1),
              content: _buildDataPendidikanStep(),
            ),
            Step(
              title: const Text('Track & Peminatan'),
              subtitle: const Text('Pilihan program yang diminati'),
              isActive: _currentStep >= 2,
              state: _stepState(2),
              content: _buildTrackStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    if (_currentStep == 2) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _back,
              child: const Text('Kembali'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: _simpanDraft,
              child: const Text('Simpan Draft'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: _simpanDanLanjut,
              child: const Text('Simpan & Lanjut'),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _back,
              child: const Text('Kembali'),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: FilledButton(
            onPressed: _next,
            child: const Text('Lanjut'),
          ),
        ),
      ],
    );
  }

  Widget _buildDataDiriStep() {
    return Form(
      key: _formDiriKey,
      child: Column(
        children: [
          TextFormField(
            controller: _namaController,
            decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            textInputAction: TextInputAction.next,
            validator: _validateNama,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nikController,
            decoration: const InputDecoration(
              labelText: 'NIK',
              hintText: '16 digit',
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            maxLength: 16,
            validator: _validateNik,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _tempatLahirController,
            decoration: const InputDecoration(labelText: 'Tempat Lahir'),
            validator: requiredField('Tempat lahir'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _tanggalLahirController,
            decoration: const InputDecoration(
              labelText: 'Tanggal Lahir',
              hintText: 'contoh: 2004-01-01',
            ),
            validator: requiredField('Tanggal lahir'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _jenisKelamin,
            items: const [
              DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
              DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
            ],
            decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
            onChanged: (value) => setState(() => _jenisKelamin = value),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Pilih jenis kelamin' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _alamatController,
            decoration: const InputDecoration(labelText: 'Alamat'),
            maxLines: 3,
            validator: requiredField('Alamat'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _teleponController,
            decoration: const InputDecoration(labelText: 'No. Telepon'),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: _validateTelepon,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildDataPendidikanStep() {
    return Form(
      key: _formPendidikanKey,
      child: Column(
        children: [
          TextFormField(
            controller: _asalSekolahController,
            decoration: const InputDecoration(labelText: 'Asal Sekolah'),
            validator: requiredField('Asal sekolah'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _jurusanController,
            decoration: const InputDecoration(labelText: 'Jurusan'),
            validator: requiredField('Jurusan'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _tahunLulusController,
            decoration: const InputDecoration(
              labelText: 'Tahun Lulus',
              hintText: 'contoh: 2024',
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
            validator: _validateTahunLulus,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _rataRataNilaiController,
            decoration: const InputDecoration(
              labelText: 'Rata-rata Nilai',
              hintText: 'contoh: 88.5',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateRataRata,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStep() {
    final track = _selectedTrack;
    final peminatan = _selectedPeminatan;
    return Form(
      key: _formTrackKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<Track>(
            initialValue: track,
            items: MockData.tracks
                .map((t) => DropdownMenuItem(value: t, child: Text(t.nama)))
                .toList(),
            decoration: const InputDecoration(labelText: 'Track Program'),
            onChanged: (value) => setState(() {
              _selectedTrack = value;
              _selectedPeminatan = null;
            }),
            validator: (value) => value == null ? 'Pilih track program' : null,
          ),
          if (track == null) ...[
            const SizedBox(height: 10),
            const _TrackHint(
              text: 'Pilih track program terlebih dahulu untuk melihat pilihan peminatan.',
            ),
          ],
          if (track != null) ...[
            const SizedBox(height: 20),
            Text(
              'Pilih Peminatan',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final p in track.peminatanList)
              _PeminatanTile(
                peminatan: p,
                selected: peminatan?.id == p.id,
                onTap: () => setState(() => _selectedPeminatan = p),
              ),
            if (peminatan == null) ...[
              const SizedBox(height: 8),
              const _TrackHint(
                text: 'Pilih salah satu peminatan di atas untuk melanjutkan.',
              ),
            ],
          ],
          if (track != null && peminatan != null) ...[
            const SizedBox(height: 8),
            _PeminatanInfoPanel(track: track, peminatan: peminatan),
          ],
        ],
      ),
    );
  }
}

/// Petunjuk ringan bila track atau peminatan belum dipilih.
class _TrackHint extends StatelessWidget {
  const _TrackHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.warning,
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

/// Tile pilihan peminatan yang menyerupai pilihan radio.
class _PeminatanTile extends StatelessWidget {
  const _PeminatanTile({
    required this.peminatan,
    required this.selected,
    required this.onTap,
  });

  final Peminatan peminatan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peminatan.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    peminatan.deskripsi,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
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

/// Panel informasi program setelah peminatan dipilih (biaya, durasi, deskripsi).
class _PeminatanInfoPanel extends StatelessWidget {
  const _PeminatanInfoPanel({required this.track, required this.peminatan});

  final Track track;
  final Peminatan peminatan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'Informasi Program',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Track', value: track.nama),
          _InfoRow(label: 'Peminatan', value: peminatan.nama),
          _InfoRow(label: 'Biaya', value: peminatan.biaya),
          _InfoRow(label: 'Durasi', value: peminatan.durasi),
          const SizedBox(height: 12),
          const Text(
            'Deskripsi',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            track.deskripsi,
            style: const TextStyle(color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

/// Baris label-nilai untuk panel informasi.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
