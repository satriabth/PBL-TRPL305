// Implementasi stub untuk platform non-web (mis. saat menjalankan flutter test
// di Dart VM) — menyimpan data di memori agar tetap berfungsi saat diuji.

final Map<String, String> _memory = {};

String? read(String key) => _memory[key];

void write(String key, String value) => _memory[key] = value;

void remove(String key) => _memory.remove(key);
