import 'package:flutter/material.dart';
import 'package:bodyheatmap/bodyheatmap.dart';

// Only this adapter imports the third-party component. Raw IDs are preserved.
String normalizeBodyRegion(String raw) =>
    raw.trim().replaceAll(RegExp(r'\s+'), '-');

class BodyMapAdapter extends StatelessWidget {
  final Set<String> selected;
  final double width;
  final ValueChanged<String>? onSelect;
  const BodyMapAdapter({
    super.key,
    required this.selected,
    required this.width,
    this.onSelect,
  });
  @override
  Widget build(BuildContext context) => BodyHeatmap(
    selectedParts: {for (final id in selected) id: 1},
    width: width,
    baseColor: const Color(0xFFC05236),
    unselectedColor: const Color(0xFFD9E4E1),
    intensityLevels: 1,
    showLegend: false,
    onPartTap: onSelect == null
        ? null
        : (raw) => onSelect!(normalizeBodyRegion(raw)),
  );
}
