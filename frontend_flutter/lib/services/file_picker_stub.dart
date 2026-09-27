/// Stub untuk platform non-web (test/VM): mengembalikan nama contoh agar alur
/// unggah tetap dapat diuji tanpa peramban.
Future<String?> pickFileName() async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return 'contoh_berkas.pdf';
}
