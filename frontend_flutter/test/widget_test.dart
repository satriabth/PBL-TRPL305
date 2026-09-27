// Basic smoke test: aplikasi boot ke halaman splash.
import 'package:flutter_test/flutter_test.dart';

import 'package:microcredential_flutter/main.dart';

void main() {
  testWidgets('Aplikasi boot ke halaman splash', (WidgetTester tester) async {
    await tester.pumpWidget(const MicrocredentialApp());
    // Judul splash tampil.
    expect(find.text('Microcredential Polibatam'), findsOneWidget);
    // Konsumsi timer navigasi splash -> login agar tidak ada timer pending.
    await tester.pump(const Duration(seconds: 2));
  });
}
