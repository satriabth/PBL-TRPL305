import 'payment.dart';
import 'track.dart';
import 'user.dart';

/// Status registrasi mahasiswa (sesuai spesifikasi).
enum RegistrationStatus {
  draft,
  submitted,
  approvedAdmin,
  approvedKeuangan,
  selesai,
  rejectedAdmin,
  rejectedKeuangan,
}

/// Informasi tambahan status untuk kebutuhan tampilan.
extension RegistrationStatusInfo on RegistrationStatus {
  String get label => switch (this) {
        RegistrationStatus.draft => 'Draft',
        RegistrationStatus.submitted => 'Submitted',
        RegistrationStatus.approvedAdmin => 'Disetujui Admin',
        RegistrationStatus.approvedKeuangan => 'Disetujui Keuangan',
        RegistrationStatus.selesai => 'Selesai',
        RegistrationStatus.rejectedAdmin => 'Ditolak Admin',
        RegistrationStatus.rejectedKeuangan => 'Ditolak Keuangan',
      };

  /// Posisi fase pada timeline: 0=draft, 1=submitted, 2=approved admin,
  /// 3=approved keuangan, 4=selesai. Status tolak menunjuk fase tempat kegagalan.
  int get progressStep => switch (this) {
        RegistrationStatus.draft => 0,
        RegistrationStatus.submitted => 1,
        RegistrationStatus.approvedAdmin => 2,
        RegistrationStatus.approvedKeuangan => 3,
        RegistrationStatus.selesai => 4,
        RegistrationStatus.rejectedAdmin => 2,
        RegistrationStatus.rejectedKeuangan => 3,
      };

  bool get isRejected =>
      this == RegistrationStatus.rejectedAdmin ||
      this == RegistrationStatus.rejectedKeuangan;
}

/// Data diri calon mahasiswa (langkah 1 formulir multi-step).
class DataDiri {
  String nama;
  String nik;
  String tempatLahir;
  String tanggalLahir;
  String jenisKelamin;
  String alamat;
  String telepon;
  String email;

  DataDiri({
    this.nama = '',
    this.nik = '',
    this.tempatLahir = '',
    this.tanggalLahir = '',
    this.jenisKelamin = '',
    this.alamat = '',
    this.telepon = '',
    this.email = '',
  });

  bool get isValid =>
      nama.trim().isNotEmpty &&
      nik.trim().isNotEmpty &&
      tempatLahir.trim().isNotEmpty &&
      tanggalLahir.trim().isNotEmpty &&
      jenisKelamin.trim().isNotEmpty &&
      alamat.trim().isNotEmpty &&
      telepon.trim().isNotEmpty &&
      email.trim().contains('@');
}

/// Data pendidikan calon mahasiswa (langkah 2 formulir multi-step).
class DataPendidikan {
  String asalSekolah;
  String jurusan;
  String tahunLulus;
  String rataRataNilai;

  DataPendidikan({
    this.asalSekolah = '',
    this.jurusan = '',
    this.tahunLulus = '',
    this.rataRataNilai = '',
  });

  bool get isValid =>
      asalSekolah.trim().isNotEmpty &&
      jurusan.trim().isNotEmpty &&
      tahunLulus.trim().isNotEmpty &&
      rataRataNilai.trim().isNotEmpty;
}

/// Dokumen persyaratan yang diunggah mahasiswa beserta status verifikasi.
class DocumentItem {
  final String jenis; // contoh: Ijazah, SKHU/Transkrip, KTP, Bukti Pendaftaran
  String fileName;
  bool verified; // status verifikasi oleh admin

  DocumentItem({required this.jenis, this.fileName = '', this.verified = false});

  bool get isEmpty => fileName.trim().isEmpty;
}

/// Data pendaftaran mahasiswa: data diri, pendidikan, track/peminatan, dokumen,
/// pembayaran, status, dan catatan verifikasi.
class Registration {
  final String id;
  final User maba;
  DataDiri dataDiri;
  DataPendidikan dataPendidikan;
  Track? track;
  Peminatan? peminatan;
  RegistrationStatus status;
  String? adminNote;
  String? financeNote;
  final List<DocumentItem> documents;
  Payment payment;
  DateTime? submittedAt;
  DateTime? approvedAdminAt;
  DateTime? selesaiAt;
  DateTime? rejectedAt;

  Registration({
    required this.maba,
    String? id,
    DataDiri? dataDiri,
    DataPendidikan? dataPendidikan,
    this.track,
    this.peminatan,
    this.status = RegistrationStatus.draft,
    this.adminNote,
    this.financeNote,
    Payment? payment,
    this.submittedAt,
    this.approvedAdminAt,
    this.selesaiAt,
    this.rejectedAt,
  })  : id = id ?? 'REG-${DateTime.now().millisecondsSinceEpoch}',
        dataDiri = dataDiri ?? DataDiri(),
        dataPendidikan = dataPendidikan ?? DataPendidikan(),
        payment = payment ?? Payment(),
        documents = _initialDocuments();

  static List<DocumentItem> _initialDocuments() => [
        DocumentItem(jenis: 'Ijazah'),
        DocumentItem(jenis: 'SKHU / Transkrip'),
        DocumentItem(jenis: 'KTP'),
        DocumentItem(jenis: 'Bukti Pendaftaran'),
      ];

  /// Seluruh formulir (data diri, pendidikan, track & peminatan) telah lengkap.
  bool get dataLengkap =>
      dataDiri.isValid &&
      dataPendidikan.isValid &&
      track != null &&
      peminatan != null;

  /// Seluruh dokumen persyaratan telah diunggah.
  bool get dokumenLengkap => documents.every((d) => !d.isEmpty);

  /// Bukti pembayaran telah diunggah.
  bool get pembayaranLengkap =>
      payment.buktiFileName != null && payment.buktiFileName!.trim().isNotEmpty;

  /// Semua prasyarat submit terpenuhi.
  bool get siapSubmit => dataLengkap && dokumenLengkap && pembayaranLengkap;
}
