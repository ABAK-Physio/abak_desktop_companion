import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_shared/abak_shared.dart';

class ExerciseEvolutionDetailScreen extends StatelessWidget {
  final String exoId;
  final List<DesktopResult> measures;
  final String patientName;

  const ExerciseEvolutionDetailScreen({
    super.key,
    required this.exoId,
    required this.patientName,
    required this.measures,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMeasures = [...measures]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final numericMeasures = sortedMeasures
        .where((measure) => measure.scoreTotal != null)
        .toList();

    final formatter = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    final unit = sortedMeasures.isEmpty
        ? ''
        : sortedMeasures.last.measureUnit?.trim().isNotEmpty == true
        ? ' ${sortedMeasures.last.measureUnit!.trim()}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Évolution du ${ClinicalActivityCatalog.displayLabel(exoId)}",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            ClinicalActivityCatalog.displayLabel(exoId),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                patientName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (numericMeasures.length >= 2) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 260,
                  child: _EvolutionLineChart(
                    measures: numericMeasures,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...sortedMeasures.map((result) {
            final date = formatter.format(
              DateTime.fromMillisecondsSinceEpoch(result.createdAt),
            );

            final value = result.scoreTotal == null
                ? '-'
                : '${result.scoreTotal!.toStringAsFixed(2)}$unit';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.timeline),
                title: Text(value),
                subtitle: Text(date),
              ),
            );
          }),
        ],
      ),
    );
  }
}
class _EvolutionLineChart extends StatelessWidget {
  final List<DesktopResult> measures;

  const _EvolutionLineChart({
    required this.measures,
  });

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];

    for (int i = 0; i < measures.length; i++) {
      spots.add(
        FlSpot(
          i.toDouble(),
          measures[i].scoreTotal!,
        ),
      );
    }

    final values = measures.map((measure) => measure.scoreTotal!).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = maxValue - minValue;

    final minY = range == 0 ? minValue - 1 : minValue - range * 0.15;
    final maxY = range == 0 ? maxValue + 1 : maxValue + range * 0.15;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 || index >= measures.length) {
                  return const SizedBox.shrink();
                }

                final formatter = DateFormat.Md(
                  Localizations.localeOf(context).toLanguageTag(),
                );

                final date = DateTime.fromMillisecondsSinceEpoch(
                  measures[index].createdAt,
                );

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    formatter.format(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}


