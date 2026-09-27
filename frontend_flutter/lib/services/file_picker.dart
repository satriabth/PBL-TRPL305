import 'file_picker_stub.dart'
    if (dart.library.html) 'file_picker_web.dart' as impl;

/// Memilih nama file dari peramban web; null bila dibatalkan/gagal.
/// Pada platform non-web mengembalikan nama contoh untuk keperluan pengujian.
Future<String?> pickFileName() => impl.pickFileName();
