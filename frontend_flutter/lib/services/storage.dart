import 'storage_stub.dart'
    if (dart.library.html) 'storage_web.dart' as impl;

/// Penyimpanan lokal sederhana lintas platform.
/// - Web   : localStorage (lihat [storage_web.dart])
/// - Lainnya (tes/VM): in-memory (lihat [storage_stub.dart])
class AppStorage {
  AppStorage._();

  static const String draftKeyPrefix = 'mc_draft_'; // + email pendaftar

  static String? read(String key) => impl.read(key);

  static void write(String key, String value) => impl.write(key, value);

  static void remove(String key) => impl.remove(key);

  static String draftKey(String email) => '$draftKeyPrefix${email.toLowerCase()}';
}
