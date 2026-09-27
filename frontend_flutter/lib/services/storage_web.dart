// Implementasi web: menyimpan data ke localStorage browser.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

final Map<String, String> _memory = {};

String? read(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return _memory[key];
  }
}

void write(String key, String value) {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {
    _memory[key] = value;
  }
}

void remove(String key) {
  try {
    html.window.localStorage.remove(key);
  } catch (_) {
    _memory.remove(key);
  }
}
