import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:svg_path_parser/svg_path_parser.dart';

// Extension for Color to Hex conversion (kept for consistency)
extension HexColor on Color {
  String toHex({bool leadingHashSign = true, bool withAlpha = false}) {
    final buffer = StringBuffer();
    if (leadingHashSign) buffer.write('#');
    if (withAlpha) {
      buffer.write(
        (a * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0'),
      );
    }
    buffer
      ..write(
        (r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0'),
      )
      ..write(
        (g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0'),
      )
      ..write(
        (b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0'),
      );
    return buffer.toString().toUpperCase();
  }
}

class BodyHeatmap extends StatefulWidget {
  final Map<String, int> selectedParts;
  final Color unselectedColor;
  final Color baseColor;
  final double width;
  final bool showLegend;
  final TextStyle legendTextStyle;
  final MainAxisAlignment legendAlignment;
  final int intensityLevels;
  final void Function(String part)? onPartTap;

  // Constants for SVG dimensions
  static const double svgViewBoxWidth = 319;
  static const double svgViewBoxHeight = 295;

  const BodyHeatmap({
    super.key,
    required this.selectedParts,
    required this.baseColor,
    this.unselectedColor = const Color(0xFFCCCCCC),
    this.width = 300,
    this.showLegend = false,
    this.legendTextStyle = const TextStyle(fontSize: 14, color: Colors.black),
    this.legendAlignment = MainAxisAlignment.center,
    this.intensityLevels = 3,
    this.onPartTap,
  });

  @override
  State<BodyHeatmap> createState() => _BodyHeatmapState();
}

class _BodyHeatmapState extends State<BodyHeatmap> {
  String? _hoveredPart;
  String? _activePart;

  // Cache to store Path objects generated from SVG 'd' attributes
  static final Map<String, ui.Path> _pathCache = {};

  // --- Core Logic: Map SVG Path IDs to Canonical Part Names ---
  static const Map<String, String> _pathToPartMap = {
    // Front View
    'head-1': 'front-head',
    'neck-front-right': 'front-neck-right',
    'neck-front-left': 'front-neck-left',
    'chest-left-top': 'front-chest-left',
    'chest-right-top': 'front-chest-right',
    'shoulder-right-top': 'front-shoulder-right',
    'shoulder-left-top': 'front-shoulder-left',
    'arm-front-right-1': 'front-arm-right',
    'arm-front-right-2': 'front-arm-right',
    'arm-front-right-3': 'front-arm-right',
    'arm-front-right-4': 'front-arm-right',
    'arm-front-right-5': 'front-arm-right',
    'arm-front-left-1': 'front-arm-left',
    'arm-front-left-2': 'front-arm-left',
    'arm-front-left-3': 'front-arm-left',
    'arm-front-left-4': 'front-arm-left',
    'hand-front-left-1': 'front-palm-left',
    'hand-front-right-1': 'front-palm-right',
    'abs-front-1': 'front-abs',
    'abs-front-2': 'front-abs',
    'abs-front-3': 'front-abs',
    'abs-front-4': 'front-abs',
    'abs-front-5': 'front-abs',
    'abs-front-6': 'front-hip-left',
    'abs-front-7': 'front-hip-right',
    'abs-front-8': 'front-abs',
    'abs-front-9': 'front-abs',
    'abs-front-10': 'front-abs',
    'abs-front-11': 'front-abs',
    'abs-front-12': 'front-abs',
    'abs-front-13': 'front-abs',
    'abs-front-14': 'front-abs',
    'abs-front-15': 'front-abs',
    'abs-front-16': 'front-abs',
    'abs-front-17': 'front-abs',
    'abs-front-18': 'front-abs',
    'abs-front-19': 'front-abs',
    'abs-front-20': 'front-abs',
    'leg-front-left-1': 'front-leg-left',
    'leg-front-right-1': 'front-leg-right',
    'leg-front-left-2': 'front-leg-left',
    'leg-front-mid-left-1': 'front-leg-left',
    'leg-front-mid-right-1': 'front-leg-right',
    'leg-front-left-3': 'front-leg-left',
    'leg-front-mid-left-2': 'front-leg-left',
    'leg-front-mid-right-2': 'front-leg-right',
    'leg-front-right-2': 'front-leg-right',
    'foot-front-left-1': 'front-knee-left',
    'foot-front-left-2': 'front-knee-left',
    'foot-front-mid-left': 'front-knee-left',
    'foot-front-mid-right': 'front-knee-right',
    'foot-front-right-1': 'front-knee-right',
    'foot-front-right-2': 'front-knee-right',
    'foot-front-toes-left': 'front-foot-left',
    'foot-front-toes-right': 'front-foot-right',

    // Back View
    'head-back-1': 'back-head',
    'neck-back-right': 'back-neck-right',
    'neck-back-left': 'back-neck-left',
    'shoulder-back-right-1': 'back-shoulder-right',
    'shoulder-back-left-1': 'back-shoulder-left',
    'arm-back-left-1': 'back-arm-left',
    'arm-back-left-2': 'back-arm-left',
    'arm-back-left-3': 'back-arm-left',
    'arm-back-right-1': 'back-arm-right',
    'arm-back-right-2': 'back-arm-right',
    'arm-back-right-3': 'back-arm-right',
    'hand-back-right-1': 'back-hand-right',
    'hand-back-left-1': 'back-hand-left',
    'back-mid-right-1': 'back-upper-right',
    'back-mid-left-1': 'back-upper-left',
    'back-left-top': 'back-upper-left',
    'back-right-top': 'back-upper-right',
    'back-mid-right-2': 'back-mid-right',
    'back-mid-left-2': 'back-mid-left',
    'butt-left': 'back-butt-left',
    'butt-right': 'back-butt-right',
    'butt-mid-right-1': 'back-butt-right',
    'butt-mid-left-1': 'back-butt-left',
    'leg-back-right-1': 'back-leg-right',
    'leg-back-right-2': 'back-leg-right',
    'leg-back-mid-right': 'back-leg-left',
    'leg-back-left-1': 'back-leg-left',
    'leg-back-left-2': 'back-leg-left',
    'leg-back-mid-left': 'back-leg-left',
    'leg-back-right-3': 'back-leg-right',
    'leg-back-right-4': 'back-leg-right',
    'leg-back-right-5': 'back-leg-right',
    'leg-back-mid-right-2': 'back-leg-right',
    'leg-back-mid-left-2': 'back-leg-left',
    'leg-back-left-3': 'back-leg-left',
    'leg-back-right-6': 'back-leg-right',
    'leg-back-left-4': 'back-leg-left',
  };

  // --- Utility Methods ---
  String defaultColor() => widget.unselectedColor.toHex(leadingHashSign: true);

  // Calculates the fill color based on the selected intensity value
  String fillSvg(String part) {
    // Highlight hovered or active parts with high priority
    if (part == _hoveredPart || part == _activePart) {
      return widget.baseColor
          .withValues(alpha: 0.9)
          .toHex(leadingHashSign: true);
    }

    // Check if this part is persistently selected
    if (widget.selectedParts.containsKey(part) &&
        widget.selectedParts[part]! > 0) {
      return widget.baseColor.toHex(leadingHashSign: true);
    }

    return defaultColor();
  }

  // Calculates the opacity based on the selected intensity value
  double fillOpacity(String part) {
    final canonicalName = _pathToPartMap.entries
        .firstWhere(
          (entry) => entry.value == part,
          orElse: () => const MapEntry('', ''),
        )
        .value;

    final value =
        widget.selectedParts[canonicalName.isNotEmpty ? canonicalName : part];

    if (value == null || value == 0) return 1.0;

    final allValues = widget.selectedParts.values.where((v) => v > 0);
    if (allValues.isEmpty) return 1.0;

    final min = allValues.reduce((a, b) => a < b ? a : b);
    final max = allValues.reduce((a, b) => a > b ? a : b);

    final normalized = max == min ? 1.0 : (value - min) / (max - min);

    final steps = List.generate(
      widget.intensityLevels,
      (i) => (i + 1) / widget.intensityLevels,
    );
    final index = (normalized * (steps.length - 1)).round().clamp(
      0,
      steps.length - 1,
    );

    return steps[index];
  }

  // Calculates the stroke width for hover/active/selected states
  String getStrokeWidth(String part) {
    if (part == _activePart) return '3';
    if (part == _hoveredPart) return '2';
    // Persistent highlight for selected parts
    if (widget.selectedParts.containsKey(part) &&
        widget.selectedParts[part]! > 0) {
      return '1.5';
    }
    return '0';
  }

  // Gets stroke color for hover/active/selected states
  String getStrokeColor(String part) {
    if (part == _activePart) {
      return Colors.white.toHex(
        leadingHashSign: true,
      ); // Bright white for active tap
    }
    if (part == _hoveredPart) {
      return widget.baseColor
          .withValues(alpha: 1.0)
          .toHex(leadingHashSign: true);
    }
    // Persistent highlight for selected parts
    if (widget.selectedParts.containsKey(part) &&
        widget.selectedParts[part]! > 0) {
      return widget.baseColor
          .withValues(alpha: 1.0)
          .toHex(leadingHashSign: true);
    }
    return 'none';
  }

  List<Widget> buildLegend() {
    const totalWidth = 80.0;
    const height = 15.0;
    final boxWidth = totalWidth / widget.intensityLevels;
    return List.generate(widget.intensityLevels, (i) {
      final opacity = (i + 1) / widget.intensityLevels;
      return Container(
        height: height,
        width: boxWidth,
        decoration: BoxDecoration(
          color: widget.baseColor.withValues(alpha: opacity),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
      );
    });
  }

  // --- Path Parsing and Hit-Testing ---

  // Parses the raw SVG string to extract path data and populate the cache.
  void _parseSvgPaths() {
    if (_pathCache.isNotEmpty) return; // Already parsed

    final pathRegex = RegExp(r'<path[^>]*id="([^"]*)"[^>]*d="([^"]*)"');
    final matches = pathRegex.allMatches(data());

    for (final match in matches) {
      final id = match.group(1);
      final dAttribute = match.group(2);

      if (id != null && dAttribute != null && _pathToPartMap.containsKey(id)) {
        try {
          // *** FIX APPLIED HERE: Use parseSvgPathData from path_parsing ***
          final path = parseSvgPath(dAttribute);
          _pathCache[id] = path;
        } catch (e) {
          debugPrint('Error parsing path ID $id: $e');
        }
      }
    }
  }

  // Performs the hit-test on all relevant paths
  String? _hitTestPath(ui.Offset localTapOffset) {
    final scaleFactor = widget.width / BodyHeatmap.svgViewBoxWidth;

    // Convert the local tap offset (screen pixels) back to SVG viewBox coordinates
    final svgTapPoint = ui.Offset(
      localTapOffset.dx / scaleFactor,
      localTapOffset.dy / scaleFactor,
    );

    for (final entry in _pathToPartMap.entries) {
      final pathId = entry.key;
      final canonicalPartName = entry.value;

      final path = _pathCache[pathId];
      if (path != null) {
        if (path.contains(svgTapPoint)) {
          return canonicalPartName.replaceAll("-", " ");
        }
      }
    }

    return null; // No body part was hit
  }

  // --- Build Method ---

  Widget _buildInteractiveSvg() {
    _parseSvgPaths();
    final double scaleFactor = widget.width / BodyHeatmap.svgViewBoxWidth;

    return MouseRegion(
      onHover: (event) {
        final localHoverOffset = event.localPosition;
        final hoveredPart = _hitTestPath(localHoverOffset);

        if (hoveredPart != _hoveredPart) {
          setState(() {
            _hoveredPart = hoveredPart;
          });
        }
      },
      onExit: (_) {
        if (_hoveredPart != null) {
          setState(() {
            _hoveredPart = null;
          });
        }
      },
      child: GestureDetector(
        onTapDown: (details) {
          final localTapOffset = details.localPosition;
          final tappedPart = _hitTestPath(localTapOffset);

          if (tappedPart != null) {
            setState(() {
              _activePart = tappedPart;
            });
          }
        },
        onTapUp: (details) {
          final localTapOffset = details.localPosition;
          final tappedPart = _hitTestPath(
            localTapOffset,
          ); // Returns hyphenated ID

          if (tappedPart != null) {
            widget.onPartTap?.call(tappedPart);
            debugPrint(
              'Tapped on part: ${tappedPart.replaceAll("-", " ")} (Shape Hit)',
            );
          }

          // Reset active state after a short delay
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() {
                _activePart = null;
              });
            }
          });
        },
        onTapCancel: () {
          setState(() {
            _activePart = null;
          });
        },
        child: SizedBox(
          width: widget.width,
          height: BodyHeatmap.svgViewBoxHeight * scaleFactor,
          child: SvgPicture.string(
            data(),
            width: widget.width,
            fit: BoxFit.contain,
            allowDrawingOutsideViewBox: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.width,
          child: Column(
            children: [
              _buildInteractiveSvg(),
              const SizedBox(height: 30),
              if (widget.showLegend)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: widget.legendAlignment,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Low', style: widget.legendTextStyle),
                          const SizedBox(width: 5),
                          Row(children: buildLegend()),
                          const SizedBox(width: 5),
                          Text('High', style: widget.legendTextStyle),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Full SVG Data (Reconstructed) ---
  String data() {
    String svgContent = '''
          <svg width="319" height="295" viewBox="0 0 319 295" fill="none" xmlns="http://www.w3.org/2000/svg">
        ''';

    // Helper to generate a single path string with dynamic styling
    String generatePath(String id, String d, String canonicalPart) {
      final fillColor = fillSvg(canonicalPart);
      final opacity = fillOpacity(canonicalPart);
      final strokeWidth = getStrokeWidth(canonicalPart);
      final strokeColor = getStrokeColor(canonicalPart);

      // Keep SVG attributes explicit for XML-aware Dart editors.
      String transform = 'matrix(1, 0, 0, 1, 0, 0)';
      if (canonicalPart == _activePart) {
        // Look up center of the path for "scale-in-place"
        final path = _pathCache[id];
        if (path != null) {
          final bounds = path.getBounds();
          final cx = bounds.center.dx;
          final cy = bounds.center.dy;
          const scale = 1.2;
          // matrix(a, b, c, d, tx, ty)
          // tx = cx * (1 - scale)
          // ty = cy * (1 - scale)
          final tx = cx * (1 - scale);
          final ty = cy * (1 - scale);
          transform = 'matrix($scale, 0, 0, $scale, $tx, $ty)';
        }
      }

      return '<path id="$id" d="$d" fill="$fillColor" fill-opacity="$opacity" stroke="$strokeColor" stroke-width="$strokeWidth" transform="$transform"/>';
    }

    // Iterate through the paths to build the SVG dynamically
    _pathToPartMap.forEach((id, canonicalPart) {
      String dAttribute = ''; // Placeholder for d attribute

      switch (id) {
        case 'head-1':
          dAttribute =
              'M69 0L63 4V14H60.5V19.5C61.3333 20 63 21.2 63 22V30L69 34H79L84.5 30V22L87.5 19.5V14H84.5V4L79 0H69Z';
          break;
        case 'neck-front-right':
          dAttribute = 'M84.5 39.5V34L78 39.5V47H95.5L84.5 39.5Z';
          break;
        case 'neck-front-left':
          dAttribute = 'M65 40.5V35L67 34L71 39.5L71.5 47H54L65 40.5Z';
          break;
        case 'chest-left-top':
          dAttribute = 'M71 73.5V55L57.5 50L51.5 63L47.5 67.5L61.5 75L71 73.5Z';
          break;
        case 'chest-right-top':
          dAttribute =
              'M77 54L86.5 50H92.5L98.5 64L102 66V68L85.5 75L77 73.5V54Z';
          break;
        case 'shoulder-right-top':
          dAttribute = 'M113.5 57.5L109 51H102.5L109 60L111.5 66.5H113.5V57.5Z';
          break;
        case 'shoulder-left-top':
          dAttribute = 'M36.5 57V67L47 51H40.5L36.5 57Z';
          break;
        case 'arm-front-right-1':
          dAttribute =
              'M110 70H101.5L102.5 81.5L105 87L111.5 93.5H115V87L110 70Z';
          break;
        case 'arm-front-right-2':
          dAttribute =
              'M119 79.5L115 74L115.5 93.5L117 94.5L120 91.5L119 79.5Z';
          break;
        case 'arm-front-right-3':
          dAttribute = 'M114 103L107 98L106.506 93.5509L115.5 101V103H114Z';
          break;
        case 'arm-front-right-4':
          dAttribute =
              'M121 96H117.5V107L132.5 132L135 131L126.5 118V110L121 96Z';
          break;
        case 'arm-front-right-5':
          dAttribute =
              'M115 120.5L108 101L116 106.5L129.5 131L128 135L115 120.5Z';
          break;
        case 'arm-front-left-1':
          dAttribute =
              'M38 70H47L46 81.5L44 87L38 93.5509H34V96L30.5 92.5V81L34 74.5V87L38 70Z';
          break;
        case 'arm-front-left-2':
          dAttribute = 'M42 98V93.5509L34 101L35.5 103L42 98Z';
          break;
        case 'arm-front-left-3':
          dAttribute = 'M30.5 105V96H27L21 118L14.5 131L17 132L30.5 105Z';
          break;
        case 'arm-front-left-4':
          dAttribute = 'M19.5 132L23 135L35.5 118L42 101L34 105L19.5 132Z';
          break;
        case 'hand-front-left-1':
          dAttribute =
              'M15.5 138L13.5 134.5L7 135L0 141.5L4 142L6 139.5L7 142L1 153L4 154L7 147L8.5 147.5L5.5 156H9L11 148L13 149L10.5 156L13.5 156.5L15.5 149H17L16.5 156.5L19 155.5L20 147.5L21 147L20.5 138H15.5Z';
          break;
        case 'hand-front-right-1':
          dAttribute =
              'M130.5 156.5L129 149.5V137.5H134V134H139L148.5 140V142H145L141.5 140L141 142.5L147.5 154L144.5 154.5L141.5 149L140.5 149.5L143.5 155.5L140 156L137.5 150H135.5L137.5 156H135L132.5 150L131.5 150.5L132.5 155.5L130.5 156.5Z';
          break;
        case 'abs-front-1':
          dAttribute = 'M50 75.5V72L52 75.5H50Z';
          break;
        case 'abs-front-2':
          dAttribute = 'M60 77L55.5 75.5L54.5 78L60 79.5V77Z';
          break;
        case 'abs-front-3':
          dAttribute = 'M57 92L49.5 82.5V78.5L51.5 78L52 80L57.5 86.5L57 92Z';
          break;
        case 'abs-front-4':
          dAttribute = 'M52.5 79.5V78L59 81L58 86L52.5 79.5Z';
          break;
        case 'abs-front-5':
          dAttribute = 'M49.5 93.5V86.5L57.5 96V101H55.5L49.5 93.5Z';
          break;
        case 'abs-front-6':
          dAttribute =
              'M59.5 105L53 102.5L52 120.5L62 127.5V125L60.5 121.5L59.5 105Z';
          break;
        case 'abs-front-7':
          dAttribute =
              'M96 102.5L89.5 106L89 121L87.5 125V127.5H89.5L97.5 121.5L96 102.5Z';
          break;
        case 'abs-front-8':
          dAttribute = 'M92.5 101V95L96 92L100.5 86.5L99 95L92.5 101Z';
          break;
        case 'abs-front-9':
          dAttribute = 'M93 92.5L92.5 86.5L97.5 81V78L100.5 78.5V82.5L93 92.5Z';
          break;
        case 'abs-front-10':
          dAttribute = 'M96 78L90.5 81.5V86L92 85.5L96 81.5V78Z';
          break;
        case 'abs-front-11':
          dAttribute = 'M93 75.5L89.5 78L95.5 77.5L96 75.5H93Z';
          break;
        case 'abs-front-12':
          dAttribute = 'M100.5 75.5L97.5 72V76L100.5 75.5Z';
          break;
        case 'abs-front-13':
          dAttribute =
              'M69 78.5L60.5 82.5L61 87.5H63.5L68.5 84L72 83.5V78L69 78.5Z';
          break;
        case 'abs-front-14':
          dAttribute = 'M77.5 84V78.5H82V79L88 81.5V87.5H86L82.5 84H77.5Z';
          break;
        case 'abs-front-15':
          dAttribute = 'M72 96V88.5L62 92V97.5L65 96H72Z';
          break;
        case 'abs-front-16':
          dAttribute = 'M77.5 96V88.5L87.5 91V97.5L84.5 96H77.5Z';
          break;
        case 'abs-front-17':
          dAttribute = 'M62 107V101L72 100.5V110L69 109L62 107Z';
          break;
        case 'abs-front-18':
          dAttribute = 'M78 110L77.5 101H87.5V108L81.5 109L78 110Z';
          break;
        case 'abs-front-19':
          dAttribute = 'M70.5 112L62 111L66 134L72 136L70.5 112Z';
          break;
        case 'abs-front-20':
          dAttribute = 'M86 112H77.5L76.5 136L82.5 134L86 112Z';
          break;
        case 'leg-front-left-1':
          dAttribute =
              'M49.5 123.5L52.5 126L51 164.5L60 199L54.5 164.5V143.5L64.5 166L63.5 198L60 199H57.5L47.5 166L49.5 123.5Z';
          break;
        case 'leg-front-right-1':
          dAttribute =
              'M96 127L99 123.5L100.5 166L91.5 199H88.5H86L82.1556 169.206L82 168L80.5 162L93.5 131.5V142.5L82 168L82.1556 169.206L96 142.5L95 166L88.5 199L97.5 166L96 127Z';
          break;
        case 'leg-front-left-2':
          dAttribute = 'M56 142.5V131.5L60 142.5L68 162V168L56 142.5Z';
          break;
        case 'leg-front-mid-left-1':
          dAttribute = 'M73.5 189L68 171.5L65.5 200L69.5 201.5L73.5 189Z';
          break;
        case 'leg-front-mid-right-1':
          dAttribute = 'M76.5 189L80.5 171.5L82.1556 200L78.5 201.5L76.5 189Z';
          break;
        case 'leg-front-left-3':
          dAttribute =
              'M63.5 229.5L57.5 216.5L53.5 238.5L63.5 270.5L68 272.5L63.5 254V229.5Z';
          break;
        case 'leg-front-mid-left-2':
          dAttribute = 'M68 261V224L72.5 229.5L71 246L69.5 266.5L68 261Z';
          break;
        case 'leg-front-mid-right-2':
          dAttribute =
              'M78.5 242.5V224L82.1556 231.5L83 248.5L80 266.5V247L78.5 242.5Z';
          break;
        case 'leg-front-right-2':
          dAttribute =
              'M86 226.5L91.5 216.5L95 238.5L86 269.5L83 272.5L80 270.5L86 248.5V226.5Z';
          break;
        case 'foot-front-left-1':
          dAttribute = 'M54.5 211.5V202.5L59.5 212L54.5 211.5Z';
          break;
        case 'foot-front-left-2':
          dAttribute = 'M59.5 209.5V205L67.5 206L63 216.5L59.5 209.5Z';
          break;
        case 'foot-front-mid-left':
          dAttribute =
              'M65.5 216.5L70.5 206L72 213.5L68.5 222L65.5 222.5V216.5Z';
          break;
        case 'foot-front-mid-right':
          dAttribute =
              'M76.5 213.5V205L83.5 216.5L82.5 223.5L80 222.5L76.5 213.5Z';
          break;
        case 'foot-front-right-1':
          dAttribute =
              'M84.5 214.5L82.5 205H90L87.5 211.5L86.5 216.5H84.5V214.5Z';
          break;
        case 'foot-front-right-2':
          dAttribute = 'M89.5 211.5L94 201.5V211.5H89.5Z';
          break;
        case 'foot-front-toes-left':
          dAttribute =
              'M71.5 291V276L63 277.5L58 288.5L65 291H67.5L68.5 287.5V291H71.5Z';
          break;
        case 'foot-front-toes-right':
          dAttribute =
              'M77 291V274.5L83 276L91 285.5L89.5 290H84.5V292L77 291Z';
          break;
        case 'head-back-1':
          dAttribute =
              'M229 20L230.5 28L234 24.5V20H245V24.5V28L250 26.5V18L252.5 14L250 13V4L243 0H234L227.5 7V11L225.5 14L229 20Z';
          break;
        case 'hand-back-right-1':
          dAttribute =
              'M177.5 141L176.5 137.5L167 141.5L163.5 145.5L164.5 146.5L167.5 144.5L170.5 145.5L164.5 157.5H167.5L170.5 150.5L172 151.5L168.5 160H172L174.5 151.5H177.5L174.5 160H176.5L180 152.5V159H181.5L182.5 152.5V141H177.5Z';
          break;
        case 'hand-back-left-1':
          dAttribute =
              'M299.5 141H294.5V150.5L296 159.5H298.5L297.5 151.5L299.5 153L301 160H303.5L301 153H303L305.5 160L309.5 159.5L305 151.5H307L310.5 157.5H312.5L306 144.5L308 143.5L312.5 146.5L314 145V143.5L305 137.5H301L299.5 141Z';
          break;
        case 'leg-back-right-1':
          dAttribute =
              'M228 153.5L223.5 156.5V165.5L221.5 171.5V183.5L223.5 197.5L229.5 211L232 206L231 184.5L228 176V153.5Z';
          break;
        case 'leg-back-right-2':
          dAttribute =
              'M236 149.5L231 151.5L232 179H234L235 172.5L236 168V149.5Z';
          break;
        case 'leg-back-mid-right':
          dAttribute = 'M242 167V149.5L246.5 151.5L247.5 176L245 178L242 167Z';
          break;
        case 'leg-back-left-1':
          dAttribute =
              'M250 176L248.5 153.5L253.5 154.5L254.5 159L256.5 168V183.5L253.5 198.5L251.5 203L250 208L248.5 211L246.5 207H245L246.5 187.5L250 176Z';
          break;
        case 'leg-back-left-2':
          dAttribute =
              'M259.5 183.5L258.5 160L263.5 167L266.5 183.5L262 191.5V203H259.5L257.5 191.5L259.5 183.5Z';
          break;
        case 'leg-back-mid-left':
          dAttribute =
              'M265 155.5L263.5 159V162L264 166.5L266 168.5L267.5 155.5H265Z';
          break;
        case 'leg-back-right-3':
          dAttribute = 'M212 169V155.5L215.5 160.5L214 167L212 169Z';
          break;
        case 'leg-back-right-4':
          dAttribute =
              'M214 174L217 161.5H220.5L219 170.5L217.5 184.5L220.5 191L219 197.5L217.5 203.5L215.5 203V192.5L212.5 184L214 174Z';
          break;
        case 'leg-back-right-5':
          dAttribute =
              'M222.5 203H219.5L217 214.5L215.5 235.5L221.5 246.5L223.5 242.5L221.5 235.5L222.5 203Z';
          break;
        case 'leg-back-mid-right-2':
          dAttribute =
              'M225.5 242.5V208L232 223.5L234 232.5V246.5L232 249L225.5 242.5Z';
          break;
        case 'leg-back-mid-left-2':
          dAttribute =
              'M245 223.5L254.5 208L253.5 242L245 249L244 242L245 223.5Z';
          break;
        case 'leg-back-left-3':
          dAttribute =
              'M256.5 239.5V203.5L262 216V226V239.5L258.5 246.5L254.5 245L256.5 239.5Z';
          break;
        case 'leg-back-right-6':
          dAttribute =
              'M225 246L222.5 248V254.5L225.5 265.5L226.5 288H229.5L232 252.5L225 246Z';
          break;
        case 'leg-back-left-4':
          dAttribute =
              'M253 247.5L246.5 252.5L249.246 288H251.5V270L256.5 248L253 247.5Z';
          break;
        case 'butt-left':
          dAttribute =
              'M254.5 118L251 122.5L258 125.5L263.5 133.5L264.5 131L262 121L254.5 118Z';
          break;
        case 'butt-right':
          dAttribute =
              'M227 122.5L223 118L216 121.5L213.5 133.5L215.5 132.5L220.5 125.5L227 122.5Z';
          break;
        case 'butt-mid-right-1':
          dAttribute =
              'M231 129L230 125.5L219 131L213.5 139V151.5L217.5 158L237.5 144.5L236.5 133.5L231 129Z';
          break;
        case 'butt-mid-left-1':
          dAttribute =
              'M240.5 144.5L242 132.5L249 126.5L258 129L264.5 140V152.5L262 156.5L260 158L258 154L251 151.5L240.5 144.5Z';
          break;
        case 'shoulder-back-right-1':
          dAttribute =
              'M213.5 51.5L204.5 50.5L196.5 63.5H198.5L200 67.5L213.5 51.5Z';
          break;
        case 'shoulder-back-left-1':
          dAttribute =
              'M264 53.5L278.5 67.5L280 60L275 51.5L267.5 50.5L264 53.5Z';
          break;
        case 'arm-back-left-1':
          dAttribute =
              'M270 87L272 67.5L282 77V95L278.5 96.5L275 98V95L270 87Z';
          break;
        case 'arm-back-left-2':
          dAttribute =
              'M283 104L279.5 99L278.5 104L274.5 103.5L279.5 118L288.5 127L283 115.5V104Z';
          break;
        case 'arm-back-left-3':
          dAttribute =
              'M285.5 118V101.5L290.5 103.5C292 110.5 295.1 124.7 295.5 125.5C295.9 126.3 298.333 130.5 299.5 132.5L298 135.5L296.5 138L285.5 118Z';
          break;
        case 'arm-back-right-1':
          dAttribute = 'M207 87L205.5 67.5L195 78L194 95L201.5 96.5L207 87Z';
          break;
        case 'arm-back-right-2':
          dAttribute =
              'M200 103.5V99L195 101.5L194 115.5L189.5 127H192L200 115.5L203 103.5H200Z';
          break;
        case 'arm-back-right-3':
          dAttribute =
              'M183 125.5L189.5 101.5H194L192 115.5L187 128.5L182 136.5L178 132.5L183 125.5Z';
          break;
        case 'neck-back-right':
          dAttribute =
              'M238.5 22.5H236L235 30.5L219 45H226L236 47L237 33L238.5 30.5V22.5Z';
          break;
        case 'neck-back-left':
          dAttribute =
              'M241.5 22.5H240V33L241.5 33.5L243 47.5L248.5 45L257 43.5L243.5 33.5L243 30.5L241.5 22.5Z';
          break;
        case 'back-mid-right-1':
          dAttribute = 'M220 47H212L219 52L225 67L236 75.5L235 52L220 47Z';
          break;
        case 'back-mid-left-1':
          dAttribute = 'M258 47L243 52V75.5L252 67L258 51L266 47H258Z';
          break;
        case 'back-left-top':
          dAttribute = 'M265 55.5H260L255.5 68.5L269.5 67V61L265 55.5Z';
          break;
        case 'back-right-top':
          dAttribute = 'M222.5 67L217.5 55.5H213L209 61V67H222.5Z';
          break;
        case 'back-mid-right-2':
          dAttribute =
              'M222.5 73L209 71L222.5 114.5L237 125.5L235 83L222.5 73Z';
          break;
        case 'back-mid-left-2':
          dAttribute =
              'M255.5 73L243 83L241.5 125.5L255.5 114.5L268.5 70L255.5 73Z';
          break;
        default:
          return;
      }

      svgContent += generatePath(id, dAttribute, canonicalPart);
    });

    svgContent += '</svg>';
    return svgContent;
  }
}
