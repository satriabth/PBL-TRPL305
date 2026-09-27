/// Peminatan dalam sebuah track, memuat informasi biaya dan durasi program.
class Peminatan {
  final int id;
  final String nama;
  final String deskripsi;
  final String biaya;
  final String durasi;

  const Peminatan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.biaya,
    required this.durasi,
  });
}

/// Track Microcredential berisi beberapa pilihan peminatan.
class Track {
  final int id;
  final String nama;
  final String deskripsi;
  final List<Peminatan> peminatanList;

  const Track({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.peminatanList,
  });

  Peminatan? peminatanById(int id) {
    for (final p in peminatanList) {
      if (p.id == id) return p;
    }
    return null;
  }
}
