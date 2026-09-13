import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/assessment_document_data.dart';

class AssessmentChartImageService {
  const AssessmentChartImageService();

  Future<Uint8List> buildPng({
    required AssessmentDocumentChartSeries series,
    double width = 1000,
    double height = 500,
  }) async {
    if (series.points.length < 2) {
      throw ArgumentError(
        'Une série graphique doit contenir au moins deux points.',
      );
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.white,
    );

    const left = 90.0;
    const right = 40.0;
    const top = 60.0;
    const bottom = 80.0;

    final chartWidth = width - left - right;
    final chartHeight = height - top - bottom;

    final values = series.points.map((point) => point.value).toList();

    var minValue = values.reduce((a, b) => a < b ? a : b);
    var maxValue = values.reduce((a, b) => a > b ? a : b);

    if (minValue == maxValue) {
      minValue -= 1;
      maxValue += 1;
    }

    final range = maxValue - minValue;

    final padding = range * 0.1;
    minValue -= padding;
    maxValue += padding;

    final axisPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2;

    final gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    const gridLineCount = 4;

    for (var i = 0; i <= gridLineCount; i++) {
      final ratio = i / gridLineCount;

      final y = top + chartHeight - ratio * chartHeight;

      final value = minValue + ratio * (maxValue - minValue);

      canvas.drawLine(
        Offset(left, y),
        Offset(left + chartWidth, y),
        gridPaint,
      );

      _drawText(
        canvas,
        _formatValue(value),
        Offset(15, y - 10),
        fontSize: 14,
      );
    }

    canvas.drawLine(
      const Offset(left, top),
      Offset(left, top + chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(left, top + chartHeight),
      Offset(left + chartWidth, top + chartHeight),
      axisPaint,
    );

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();

    for (var i = 0; i < series.points.length; i++) {
      final point = series.points[i];

      final x =
          left +
          (series.points.length == 1
              ? chartWidth / 2
              : chartWidth * i / (series.points.length - 1));

      final normalized = (point.value - minValue) / (maxValue - minValue);

      final y = top + chartHeight - normalized * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 6, pointPaint);

      final labelPainter = TextPainter(
        text: TextSpan(
          text: _formatValue(point.value),
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelWidth = labelPainter.width + (point.usesWalkingAid ? 26 : 0);
      final labelX = (x - labelWidth / 2).clamp(4.0, width - labelWidth - 4);
      labelPainter.paint(canvas, Offset(labelX, y - 32));
      if (point.usesWalkingAid) {
        _drawWalkingAid(canvas, Offset(labelX + labelPainter.width + 8, y - 31));
      }
      labelPainter.dispose();

      _drawText(
        canvas,
        _formatDate(point.date),
        Offset(x - 40, top + chartHeight + 18),
        fontSize: 16,
      );
    }

    canvas.drawPath(path, linePaint);

    final title = series.unit == null
        ? series.label
        : '${series.label} (${series.unit})';

    _drawText(canvas, title, const Offset(left, 15), fontSize: 22, bold: true);

    final picture = recorder.endRecording();

    final image = await picture.toImage(width.round(), height.round());

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw StateError('Impossible de convertir le graphique en image PNG.');
    }

    return byteData.buffer.asUint8List();
  }

  // Draw the cane directly so exported images do not depend on icon fonts.
  void _drawWalkingAid(Canvas canvas, Offset origin) {
    final cane = Path()
      ..moveTo(origin.dx, origin.dy + 7)
      ..cubicTo(origin.dx, origin.dy - 1, origin.dx + 12,
          origin.dy - 1, origin.dx + 12, origin.dy + 7)
      ..lineTo(origin.dx + 8, origin.dy + 23);
    canvas.drawPath(cane, Paint()
      ..color = const Color(0xFF9A4B00)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double fontSize,
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month';
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
