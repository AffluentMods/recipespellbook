import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

/// A modern HSV color picker dialog.
/// Returns the selected [Color] or null if cancelled.
Future<Color?> showColorPickerDialog(
  BuildContext context, {
  Color initialColor = const Color(0xFF6750A4),
  String? title,
}) {
  return showDialog<Color>(
    context: context,
    builder: (ctx) => _ColorPickerDialog(
      initialColor: initialColor,
      title: title,
    ),
  );
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String? title;

  const _ColorPickerDialog({
    required this.initialColor,
    this.title,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsv;
  late TextEditingController _hexController;
  bool _hexEditing = false;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
    _hexController = TextEditingController(text: _colorToHex(_hsv.toColor()));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) {
    return c.toARGB32().toRadixString(16).substring(2).toUpperCase().padLeft(6, '0');
  }

  void _updateFromHsv(HSVColor hsv) {
    setState(() {
      _hsv = hsv;
      if (!_hexEditing) {
        _hexController.text = _colorToHex(hsv.toColor());
      }
    });
  }

  void _updateFromHex(String hex) {
    hex = hex.replaceAll('#', '').trim();
    if (hex.length == 6) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) {
        final color = Color(0xFF000000 | value);
        setState(() {
          _hsv = HSVColor.fromColor(color);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = _hsv.toColor();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.title ?? l10n.colorPickerTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Saturation/Brightness square
              SizedBox(
                width: double.infinity,
                height: 200,
                child: _SatBrightnessPicker(
                  hue: _hsv.hue,
                  saturation: _hsv.saturation,
                  value: _hsv.value,
                  onChanged: (sat, val) {
                    _updateFromHsv(_hsv.withSaturation(sat).withValue(val));
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Hue slider
              SizedBox(
                width: double.infinity,
                height: 28,
                child: _HueSlider(
                  hue: _hsv.hue,
                  onChanged: (hue) {
                    _updateFromHsv(_hsv.withHue(hue));
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Color preview + hex input
              Row(
                children: [
                  // Preview circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hex input
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      decoration: InputDecoration(
                        prefixText: '#',
                        labelText: l10n.colorPickerHex,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onTap: () => _hexEditing = true,
                      onChanged: _updateFromHex,
                      onSubmitted: (_) => _hexEditing = false,
                      onEditingComplete: () => _hexEditing = false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, color),
                    child: Text(l10n.colorPickerSelect),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SATURATION / BRIGHTNESS PICKER
// ════════════════════════════════════════════

class _SatBrightnessPicker extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final void Function(double saturation, double value) onChanged;

  const _SatBrightnessPicker({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  void _handleInteraction(Offset localPos, Size size) {
    final sat = (localPos.dx / size.width).clamp(0.0, 1.0);
    final val = 1.0 - (localPos.dy / size.height).clamp(0.0, 1.0);
    onChanged(sat, val);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanStart: (d) => _handleInteraction(d.localPosition, size),
          onPanUpdate: (d) => _handleInteraction(d.localPosition, size),
          onTapDown: (d) => _handleInteraction(d.localPosition, size),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              size: size,
              painter: _SatBrightPainter(hue: hue),
              child: Stack(
                children: [
                  Positioned(
                    left: saturation * size.width - 10,
                    top: (1.0 - value) * size.height - 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SatBrightPainter extends CustomPainter {
  final double hue;
  _SatBrightPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Horizontal: saturation (left=0, right=1) with hue color
    final hueColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, hueColor],
        ).createShader(rect),
    );

    // Vertical: value/brightness (top=bright, bottom=dark)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_SatBrightPainter old) => old.hue != hue;
}

// ════════════════════════════════════════════
//  HUE SLIDER
// ════════════════════════════════════════════

class _HueSlider extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const _HueSlider({required this.hue, required this.onChanged});

  void _handleInteraction(Offset localPos, double width) {
    final newHue = (localPos.dx / width * 360.0).clamp(0.0, 359.99);
    onChanged(newHue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onPanStart: (d) => _handleInteraction(d.localPosition, width),
          onPanUpdate: (d) => _handleInteraction(d.localPosition, width),
          onTapDown: (d) => _handleInteraction(d.localPosition, width),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CustomPaint(
              size: Size(width, 28),
              painter: _HuePainter(),
              child: Stack(
                children: [
                  Positioned(
                    left: (hue / 360.0) * width - 10,
                    top: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HuePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final colors = List.generate(
      7,
      (i) => HSVColor.fromAHSV(1.0, i * 60.0, 1.0, 1.0).toColor(),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(colors: colors).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
