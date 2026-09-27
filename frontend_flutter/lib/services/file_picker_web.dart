// Implementasi web: memilih file via elemen input peramban.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<String?> pickFileName() async {
  try {
    final input = html.FileUploadInputElement()..accept = '.pdf,image/*';
    input.click();
    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) return null;
    return input.files!.first.name;
  } catch (_) {
    return null;
  }
}
