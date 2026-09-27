import '../models/contact.dart';
import '../models/faq.dart';
import '../models/track.dart';

/// Data statis / dummy sesuai dokumen spesifikasi Microcredential.
class MockData {
  MockData._();

  // Informasi pembayaran (FR-11)
  static const String bankName = 'Bank KB Bukopin';
  static const String rekeningNumber = '1003301245';
  static const String rekeningPemilik = 'Politeknik Negeri Batam (Microcredential)';
  static const String biayaPendaftaran = 'Rp200.000';

  static const List<Track> tracks = [
    Track(
      id: 1,
      nama: 'Manajemen dan Bisnis',
      deskripsi: 'Pengembangan kompetensi di bidang manajemen dan kewirausahaan.',
      peminatanList: [
        Peminatan(
            id: 101,
            nama: 'Manajemen SDM',
            deskripsi: 'Pengelolaan sumber daya manusia dan organisasi.',
            biaya: 'Rp2.000.000',
            durasi: '3 bulan'),
        Peminatan(
            id: 102,
            nama: 'Kewirausahaan',
            deskripsi: 'Perencanaan dan pengembangan usaha baru.',
            biaya: 'Rp2.500.000',
            durasi: '4 bulan'),
        Peminatan(
            id: 103,
            nama: 'Administrasi Perkantoran',
            deskripsi: 'Tata kelola administrasi perkantoran modern.',
            biaya: 'Rp2.000.000',
            durasi: '3 bulan'),
      ],
    ),
    Track(
      id: 2,
      nama: 'Teknik Elektro',
      deskripsi: 'Kompetensi praktis bidang kelistrikan dan otomasi industri.',
      peminatanList: [
        Peminatan(
            id: 201,
            nama: 'Instalasi Listrik Industri',
            deskripsi: 'Pemasangan dan pemeliharaan instalasi listrik industri.',
            biaya: 'Rp2.500.000',
            durasi: '4 bulan'),
        Peminatan(
            id: 202,
            nama: 'Otomasi & PLC',
            deskripsi: 'Pemrograman PLC untuk otomasi proses produksi.',
            biaya: 'Rp3.000.000',
            durasi: '5 bulan'),
        Peminatan(
            id: 203,
            nama: 'Elektronika Daya',
            deskripsi: 'Rangkaian daya dan pengendalian motor listrik.',
            biaya: 'Rp2.500.000',
            durasi: '4 bulan'),
      ],
    ),
    Track(
      id: 3,
      nama: 'Informatika',
      deskripsi: 'Pengembangan perangkat lunak dan teknologi informasi.',
      peminatanList: [
        Peminatan(
            id: 301,
            nama: 'Web Development',
            deskripsi: 'Pengembangan aplikasi web modern.',
            biaya: 'Rp2.500.000',
            durasi: '4 bulan'),
        Peminatan(
            id: 302,
            nama: 'Mobile Development (Flutter)',
            deskripsi: 'Pengembangan aplikasi mobile lintas platform dengan Flutter.',
            biaya: 'Rp3.000.000',
            durasi: '5 bulan'),
        Peminatan(
            id: 303,
            nama: 'Data & AI',
            deskripsi: 'Analisis data dan kecerdasan buatan terapan.',
            biaya: 'Rp3.000.000',
            durasi: '5 bulan'),
        Peminatan(
            id: 304,
            nama: 'Jaringan & Keamanan Siber',
            deskripsi: 'Administrasi jaringan dan keamanan siber dasar.',
            biaya: 'Rp2.500.000',
            durasi: '4 bulan'),
      ],
    ),
    Track(
      id: 4,
      nama: 'Teknik Mesin',
      deskripsi: 'Keterampilan manufaktur dan permesinan industri.',
      peminatanList: [
        Peminatan(
            id: 401,
            nama: 'Fabrikasi & Pengelasan',
            deskripsi: 'Teknik fabrikasi logam dan pengelasan.',
            biaya: 'Rp2.500.000',
            durasi: '4 bulan'),
        Peminatan(
            id: 402,
            nama: 'CNC & Manufaktur',
            deskripsi: 'Operasional mesin CNC dan proses manufaktur.',
            biaya: 'Rp3.000.000',
            durasi: '5 bulan'),
        Peminatan(
            id: 403,
            nama: 'Perawatan Mesin',
            deskripsi: 'Pemeliharaan dan perawatan mesin industri.',
            biaya: 'Rp2.500.000',
            durasi: '4 bulan'),
      ],
    ),
  ];

  static const List<FaqItem> faqs = [
    FaqItem(
      question: 'Apa itu program Microcredential?',
      answer:
          'Microcredential adalah program sertifikasi kompetensi singkat yang diselenggarakan Polibatam untuk mengasah keterampilan spesifik sesuai kebutuhan dunia industri.',
    ),
    FaqItem(
      question: 'Apa saja syarat pendaftaran?',
      answer:
          'Calon peserta menyiapkan ijazah, SKHU/transkrip nilai, KTP, dan bukti pendaftaran dalam bentuk softcopy untuk diunggah melalui aplikasi.',
    ),
    FaqItem(
      question: 'Berapa biaya pendaftaran awal?',
      answer:
          'Biaya pendaftaran awal sebesar Rp200.000 ditransfer ke rekening yang tertera pada halaman pembayaran, kemudian unggah bukti transfer.',
    ),
    FaqItem(
      question: 'Bagaimana cara memantau status pendaftaran saya?',
      answer:
          'Status dapat dipantau melalui menu Status pada aplikasi. Ditampilkan dalam bentuk timeline: draft, submitted, disetujui admin, hingga selesai.',
    ),
    FaqItem(
      question: 'Bagaimana jika pendaftaran saya ditolak?',
      answer:
          'Jika ditolak, catatan perbaikan dari admin atau keuangan akan ditampilkan. Perbaiki sesuai catatan lalu submit ulang.',
    ),
    FaqItem(
      question: 'Siapa yang bisa saya hubungi jika mengalami kendala?',
      answer:
          'Hubungi contact person admin pendaftaran atau bagian keuangan yang tertera pada halaman Informasi Umum.',
    ),
  ];

  static const List<ContactPerson> contacts = [
    ContactPerson(
      nama: 'Sdr. Admin Pendaftaran',
      jabatan: 'Admin Pendaftaran Microcredential',
      telepon: '0812-0000-0001',
      email: 'admin.microcredential@polibatam.ac.id',
    ),
    ContactPerson(
      nama: 'Bpk. Bagian Keuangan',
      jabatan: 'Verifikator Keuangan',
      telepon: '0812-0000-0002',
      email: 'keuangan.microcredential@polibatam.ac.id',
    ),
  ];
}
