import 'package:flutter/material.dart';

import '../theme.dart';

/// Cangkang global aplikasi yang membungkus seluruh rute:
/// 1. Pada layar lebar (desktop/web) memakai tata letak website penuh:
///    konten selebar maksimal 1240px, ditengah, dengan padding horizontal.
/// 2. Pada layar sempit (mobile) tetap tampil penuh seukuran layar.
/// 3. Banner tipis "Mode Simulasi" agar presenter menjelaskan bahwa data
///    masih contoh lokal (belum terhubung backend).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 760;
        return Column(
          children: [
            const _SimulationBanner(),
            Expanded(
              child: ColoredBox(
                color: AppColors.surface,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Padding(
                        padding: wide
                            ? const EdgeInsets.symmetric(horizontal: 20)
                            : EdgeInsets.zero,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SimulationBanner extends StatelessWidget {
  const _SimulationBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science_outlined, size: 15, color: Color(0xFF3B2E00)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Mode Simulasi — data contoh tersimpan di perangkat ini',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF3B2E00),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
