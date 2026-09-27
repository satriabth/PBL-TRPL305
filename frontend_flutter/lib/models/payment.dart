/// Status verifikasi pembayaran oleh bagian keuangan.
enum PaymentStatus { belumBayar, menungguVerifikasi, disetujui, ditolak }

/// Label tampilan untuk status pembayaran.
extension PaymentStatusLabel on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.belumBayar => 'Belum Bayar',
        PaymentStatus.menungguVerifikasi => 'Menunggu Verifikasi',
        PaymentStatus.disetujui => 'Disetujui',
        PaymentStatus.ditolak => 'Ditolak',
      };
}

/// Data pembayaran biaya pendaftaran: nominal, waktu unggah, bukti transfer, dan status verifikasi.
class Payment {
  String? buktiFileName;
  DateTime? uploadedAt;
  PaymentStatus status;
  String? catatan;

  Payment({
    this.buktiFileName,
    this.uploadedAt,
    this.status = PaymentStatus.belumBayar,
    this.catatan,
  });
}
