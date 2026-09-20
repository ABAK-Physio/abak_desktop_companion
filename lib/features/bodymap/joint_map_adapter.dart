import 'package:flutter/material.dart';
import 'joint_regions.dart';

Path jointPath(Map<String, dynamic> region) {
  final c = (region['coords'] as List).cast<num>();
  if (region['shape'] == 'circle') {
    return Path()..addOval(
      Rect.fromCircle(
        center: Offset(c[0].toDouble(), c[1].toDouble()),
        radius: c[2].toDouble(),
      ),
    );
  }
  final path = Path()..moveTo(c[0].toDouble(), c[1].toDouble());
  for (var i = 2; i < c.length; i += 2) {
    path.lineTo(c[i].toDouble(), c[i + 1].toDouble());
  }
  return path..close();
}

String? jointAt(Offset p) {
  for (final r in jointRegions) {
    if (jointPath(r).contains(p)) return r['id'] as String;
  }
  return null;
}

class JointMapAdapter extends StatelessWidget {
  final Set<String> selected;
  final double width;
  final ValueChanged<String>? onSelect;
  const JointMapAdapter({
    super.key,
    required this.selected,
    required this.width,
    this.onSelect,
  });
  @override
  Widget build(BuildContext context) {
    final w = width.clamp(0.0, 440.0);
    return Center(
      child: SizedBox(
        width: w,
        height: w * 650 / 404,
        child: GestureDetector(
          onTapUp: onSelect == null
              ? null
              : (d) {
                  final id = jointAt(d.localPosition / (w / 404));
                  if (id != null) onSelect!(id);
                },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/bodymap/rheumatoid_man.png',
                fit: BoxFit.fill,
              ),
              IgnorePointer(
                child: CustomPaint(painter: _JointPainter(selected)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JointPainter extends CustomPainter {
  final Set<String> selected;
  _JointPainter(this.selected);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 404, size.height / 650);
    final fill = Paint()..color = const Color(0xAA276F9E);
    final stroke = Paint()
      ..color = const Color(0xFF144567)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final r in jointRegions) {
      if (selected.contains(r['id'])) {
        final p = jointPath(r);
        canvas.drawPath(p, fill);
        canvas.drawPath(p, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JointPainter old) => true;
}
