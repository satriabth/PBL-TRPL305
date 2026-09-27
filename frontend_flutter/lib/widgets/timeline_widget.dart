import 'package:flutter/material.dart';

import '../theme.dart';

/// Widget timeline vertikal untuk menampilkan tahapan registrasi mahasiswa.
///
/// Setiap langkah dirender sebagai baris berisi indikator lingkaran yang
/// dihubungkan oleh garis vertikal halus:
/// - tercapai (`reached`): lingkaran 28px terisi dengan ikon centang,
/// - belum tercapai: lingkaran 28px kosong berpendar,
/// - fase tolak (`rejectedStep`): lingkaran 28px merah dengan ikon X.
///
/// Label menjadi tebal dan berwarna saat langkah tercapai, dan dapat
/// membungkus otomatis bila teksnya panjang.
///
/// Widget mandiri tanpa paket eksternal.
class TimelineWidget extends StatelessWidget {
  const TimelineWidget({
    super.key,
    required this.steps,
    this.reachedColor = AppColors.success,
    this.pendingColor = AppColors.muted,
    this.rejectedColor = AppColors.danger,
  });

  /// Daftar langkah timeline beserta statusnya.
  final List<({String label, bool reached, bool rejectedStep})> steps;

  /// Warna indikator untuk langkah yang sudah tercapai.
  final Color reachedColor;

  /// Warna indikator untuk langkah yang belum tercapai.
  final Color pendingColor;

  /// Warna indikator untuk fase tempat pendaftaran ditolak.
  final Color rejectedColor;

  /// Ukuran konsisten indikator lingkaran (px).
  static const double _indicatorSize = 28;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++) _buildStep(context, i),
      ],
    );
  }

  Widget _buildStep(BuildContext context, int index) {
    final step = steps[index];
    final isLast = index == steps.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kolom indikator: lingkaran di atas, garis penghubung di bawahnya.
          SizedBox(
            width: _indicatorSize,
            child: Column(
              children: [
                SizedBox(
                  width: _indicatorSize,
                  height: _indicatorSize,
                  child: Center(child: _buildIndicator(step)),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: step.reached ? reachedColor : pendingColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: isLast ? 0 : 22),
              child: Text(
                step.label,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.3,
                      fontWeight:
                          step.reached || step.rejectedStep
                              ? FontWeight.w700
                              : FontWeight.w400,
                      color: step.rejectedStep
                          ? rejectedColor
                          : step.reached
                              ? reachedColor
                              : null,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Memilih bentuk indikator sesuai status langkah.
  Widget _buildIndicator(({String label, bool reached, bool rejectedStep}) step) {
    if (step.rejectedStep) return _filledCircle(rejectedColor, Icons.close);
    if (step.reached) return _filledCircle(reachedColor, Icons.check);
    return _buildPendingIndicator();
  }

  /// Indikator langkah tercapai/tolak: lingkaran 28px terisi dengan ikon.
  Widget _filledCircle(Color color, IconData icon) {
    return Container(
      width: _indicatorSize,
      height: _indicatorSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }

  /// Indikator langkah belum tercapai: lingkaran 28px kosong berpendar.
  Widget _buildPendingIndicator() {
    return Container(
      width: _indicatorSize,
      height: _indicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pendingColor.withValues(alpha: 0.10),
        border: Border.all(color: pendingColor, width: 2),
      ),
    );
  }
}
