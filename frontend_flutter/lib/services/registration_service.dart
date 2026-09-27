import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/payment.dart';
import '../models/registration.dart';
import '../models/track.dart';
import '../models/user.dart';
import 'mock_data.dart';
import 'storage.dart';

/// Layanan registrasi mock: kelola data pendaftaran, draft, dokumen, pembayaran,
/// submit, dan alur verifikasi admin/keuangan. Statu disimpan di memori
/// (dengan persistensi draft di localStorage).
class RegistrationService extends ChangeNotifier {
  RegistrationService() {
    _seedDemoData();
  }

  final List<Registration> _registrations = [];

  List<Registration> get registrations => List.unmodifiable(_registrations);

  /// Registrasi yang sudah masuk antrean verifikasi (bukan draft).
  List<Registration> get submissions =>
      _registrations.where((r) => r.status != RegistrationStatus.draft).toList();

  /// Menunggu verifikasi admin (sudah submit, belum diputuskan admin).
  List<Registration> get pendingAdmin =>
      _registrations.where((r) => r.status == RegistrationStatus.submitted).toList();

  /// Menunggu verifikasi keuangan (sudah disetujui admin).
  List<Registration> get pendingFinance =>
      _registrations.where((r) => r.status == RegistrationStatus.approvedAdmin).toList();

  Registration? byId(String id) =>
      _registrations.where((r) => r.id == id).firstOrNull;

  Registration? forMaba(User maba) =>
      _registrations.where((r) => r.maba.email == maba.email).firstOrNull;

  /// Mendapatkan registrasi milik maba; membuat baru bila belum ada.
  Registration getOrCreateFor(User maba) {
    final existing = forMaba(maba);
    if (existing != null) return existing;
    final reg = Registration(maba: maba);
    _registrations.add(reg);
    notifyListeners();
    return reg;
  }

  // ---------- Mutasi data oleh maba ----------

  void updateDataDiri(Registration r, DataDiri d) {
    r.dataDiri = d;
    notifyListeners();
  }

  void updateDataPendidikan(Registration r, DataPendidikan dp) {
    r.dataPendidikan = dp;
    notifyListeners();
  }

  void selectTrackPeminatan(Registration r, Track t, Peminatan p) {
    r.track = t;
    r.peminatan = p;
    notifyListeners();
  }

  void uploadDocument(Registration r, String jenis, String fileName) {
    final doc = r.documents.where((d) => d.jenis == jenis).firstOrNull;
    if (doc != null) {
      doc.fileName = fileName;
      doc.verified = false;
    }
    notifyListeners();
  }

  void uploadBuktiBayar(Registration r, String fileName) {
    r.payment.buktiFileName = fileName;
    r.payment.uploadedAt = DateTime.now();
    r.payment.status = PaymentStatus.menungguVerifikasi;
    r.payment.catatan = null;
    notifyListeners();
  }

  /// Menyimpan draft formulir ke localStorage (FR-05 / FR-07).
  void saveDraft(Registration r) {
    AppStorage.write(AppStorage.draftKey(r.maba.email), jsonEncode(_draftJson(r)));
  }

  /// Memuat draft dari localStorage; mengembalikan null bila tidak ada.
  Registration? loadDraft(User maba) {
    final raw = AppStorage.read(AppStorage.draftKey(maba.email));
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final r = getOrCreateFor(maba);
      r.dataDiri = DataDiri(
        nama: map['nama'] ?? '',
        nik: map['nik'] ?? '',
        tempatLahir: map['tempatLahir'] ?? '',
        tanggalLahir: map['tanggalLahir'] ?? '',
        jenisKelamin: map['jenisKelamin'] ?? '',
        alamat: map['alamat'] ?? '',
        telepon: map['telepon'] ?? '',
        email: map['email'] ?? '',
      );
      r.dataPendidikan = DataPendidikan(
        asalSekolah: map['asalSekolah'] ?? '',
        jurusan: map['jurusan'] ?? '',
        tahunLulus: map['tahunLulus'] ?? '',
        rataRataNilai: map['rataRataNilai'] ?? '',
      );
      r.track = _findTrack(map['trackId']);
      r.peminatan = _findPeminatan(map['peminatanId']);
      final docs = map['documents'];
      if (docs is List) {
        for (final e in docs) {
          final m = e as Map<String, dynamic>;
          final nama = m['fileName']?.toString() ?? '';
          if (nama.isNotEmpty) {
            final doc = r.documents.where((d) => d.jenis == m['jenis']).firstOrNull;
            if (doc != null) doc.fileName = nama;
          }
        }
      }
      final bukti = map['buktiFileName']?.toString() ?? '';
      if (bukti.isNotEmpty && r.payment.buktiFileName == null) {
        uploadBuktiBayar(r, bukti);
      }
      return r;
    } catch (_) {
      return null;
    }
  }

  /// Submit pendaftaran setelah formulir, dokumen, dan bukti bayar lengkap.
  /// Mengembalikan pesan error bila belum lengkap, atau null bila berhasil.
  String? submit(Registration r) {
    if (!r.dataLengkap) return 'Lengkapi data formulir terlebih dahulu.';
    if (!r.dokumenLengkap) return 'Lengkapi seluruh dokumen persyaratan.';
    if (!r.pembayaranLengkap) return 'Unggah bukti pembayaran terlebih dahulu.';

    r.status = RegistrationStatus.submitted;
    r.submittedAt = DateTime.now();
    AppStorage.remove(AppStorage.draftKey(r.maba.email));
    notifyListeners();
    return null;
  }

  // ---------- Verifikasi admin (FR-18 / FR-19) ----------

  void approveByAdmin(Registration r) {
    r.status = RegistrationStatus.approvedAdmin;
    r.approvedAdminAt = DateTime.now();
    notifyListeners();
  }

  void rejectByAdmin(Registration r, String catatan) {
    r.status = RegistrationStatus.rejectedAdmin;
    r.adminNote = catatan;
    r.rejectedAt = DateTime.now();
    notifyListeners();
  }

  // ---------- Verifikasi keuangan (FR-20 / FR-21) ----------

  void approveByFinance(Registration r) {
    r.status = RegistrationStatus.selesai;
    r.selesaiAt = DateTime.now();
    r.payment.status = PaymentStatus.disetujui;
    notifyListeners();
  }

  void rejectByFinance(Registration r, String catatan) {
    r.status = RegistrationStatus.rejectedKeuangan;
    r.financeNote = catatan;
    r.payment.status = PaymentStatus.ditolak;
    r.payment.catatan = catatan;
    r.rejectedAt = DateTime.now();
    notifyListeners();
  }

  // ---------- Timeline ----------

  /// Data untuk timeline status registrasi:
  /// label fase, tercapai/reached, dan marker fase tolak (jika ditolak).
  List<({String label, bool reached, bool rejectedStep})> timelineFor(
      Registration r) {
    final step = r.status.progressStep;
    const labels = [
      'Draft',
      'Submitted',
      'Disetujui Admin',
      'Disetujui Keuangan',
      'Selesai',
    ];
    return labels.asMap().entries.map((e) {
      final idx = e.key;
      return (
        label: e.value,
        reached: idx <= step,
        rejectedStep: r.status.isRejected && idx == step,
      );
    }).toList();
  }

  // ---------- Internal ----------

  Map<String, dynamic> _draftJson(Registration r) => {
        'nama': r.dataDiri.nama,
        'nik': r.dataDiri.nik,
        'tempatLahir': r.dataDiri.tempatLahir,
        'tanggalLahir': r.dataDiri.tanggalLahir,
        'jenisKelamin': r.dataDiri.jenisKelamin,
        'alamat': r.dataDiri.alamat,
        'telepon': r.dataDiri.telepon,
        'email': r.dataDiri.email,
        'asalSekolah': r.dataPendidikan.asalSekolah,
        'jurusan': r.dataPendidikan.jurusan,
        'tahunLulus': r.dataPendidikan.tahunLulus,
        'rataRataNilai': r.dataPendidikan.rataRataNilai,
        'trackId': r.track?.id,
        'peminatanId': r.peminatan?.id,
        'documents': r.documents.map((d) => {'jenis': d.jenis, 'fileName': d.fileName}).toList(),
        'buktiFileName': r.payment.buktiFileName,
      };

  Track? _findTrack(int? id) {
    for (final t in MockData.tracks) {
      if (t.id == id) return t;
    }
    return null;
  }

  Peminatan? _findPeminatan(int? id) {
    for (final t in MockData.tracks) {
      final p = t.peminatanById(id ?? -1);
      if (p != null) return p;
    }
    return null;
  }

  // ---------- Data demo seed ----------

  void _seedDemoData() {
    // 1. Draft milik akun demo maba@test.com (untuk mengisi formulir).
    final satria = _registrations.where((r) => r.maba.email == 'maba@test.com').firstOrNull;
    if (satria == null) {
      _registrations.add(Registration(
        maba: const User(
          name: 'Satria Andhika',
          email: 'maba@test.com',
          password: '123456',
          role: UserRole.maba,
        ),
      ));
    }

    // 2. Submitted: menunggu verifikasi admin.
    _registrations.add(_buildFull([
      const User(
        name: 'Ayudia Permata Pabatia',
        email: 'ayudia@test.com',
        password: '123456',
        role: UserRole.maba,
      ),
    ], const [RegistrationStatus.submitted], adminNote: null));

    // 3. Approved admin: menunggu verifikasi keuangan.
    _registrations.add(_buildFull([
      const User(
        name: 'Sandhi Ar Rizki',
        email: 'sandhi@test.com',
        password: '123456',
        role: UserRole.maba,
      ),
    ], const [RegistrationStatus.approvedAdmin], adminNote: null));

    // 4. Ditolak admin: contoh catatan perbaikan.
    _registrations.add(_buildFull([
      const User(
        name: 'Echa Ana Zackhy',
        email: 'echa@test.com',
        password: '123456',
        role: UserRole.maba,
      ),
    ], const [RegistrationStatus.rejectedAdmin],
        adminNote: 'Dokumen ijazah tidak terbaca jelas. Mohon unggah ulang scan yang lebih jelas.'));
  }

  Registration _buildFull(List<User> mabas, List<RegistrationStatus> statuses,
      {String? adminNote}) {
    final r = Registration(
      maba: mabas.first,
      dataDiri: DataDiri(
        nama: mabas.first.name,
        nik: '123456789012345',
        tempatLahir: 'Batam',
        tanggalLahir: '2004-01-01',
        jenisKelamin: 'Perempuan',
        alamat: 'Jl. Contoh No. 1, Batam',
        telepon: '081234567890',
        email: mabas.first.email,
      ),
      dataPendidikan: DataPendidikan(
        asalSekolah: 'SMK Negeri 1 Batam',
        jurusan: 'Rekayasa Perangkat Lunak',
        tahunLulus: '2024',
        rataRataNilai: '88.5',
      ),
      track: MockData.tracks[2], // Informatika
      peminatan: MockData.tracks[2].peminatanList[1], // Mobile Development
      status: statuses.first,
      adminNote: adminNote,
    );
    for (final doc in r.documents) {
      doc.fileName = '${doc.jenis}_${mabas.first.name}.pdf';
      doc.verified = true;
    }
    r.payment.buktiFileName = 'bukti_transfer_${mabas.first.name}.jpg';
    r.payment.uploadedAt = DateTime.now().subtract(const Duration(days: 1));
    r.payment.status = PaymentStatus.menungguVerifikasi;
    r.submittedAt = DateTime.now().subtract(const Duration(days: 1));
    if (statuses.first == RegistrationStatus.approvedAdmin) {
      r.approvedAdminAt = DateTime.now().subtract(const Duration(hours: 5));
    }
    if (statuses.first == RegistrationStatus.rejectedAdmin) {
      r.rejectedAt = DateTime.now().subtract(const Duration(hours: 3));
      r.payment.status = PaymentStatus.belumBayar;
    }
    return r;
  }
}

