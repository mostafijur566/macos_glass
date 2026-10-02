import 'package:flutter/widgets.dart';

import 'glass.dart';
import 'theme.dart';

enum GlassSwitchSize {
  /// 28 × 12 pt — dense tables.
  mini,

  /// 36 × 16 pt — the size System Settings uses (default).
  regular,

  /// 46 × 21 pt — touch-friendly / prominent toggles.
  large,
}

/// macOS 26/27 switch, matched to System Settings: a short pill track with a
/// wide pill-shaped knob (not a circle), inset by 1 pt. Off: translucent grey
/// track and a light grey knob. On: accent track and a white knob. While
/// pressed the knob stretches toward the side it will move to.
class GlassSwitch extends StatelessWidget {
  const GlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = GlassSwitchSize.regular,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final GlassSwitchSize size;

  /// Defaults to the theme accent.
  final Color? activeColor;

  // Measured from System Settings on macOS 26/27 (points).
  static const _metrics = {
    GlassSwitchSize.mini: (w: 28.0, h: 12.0, knobW: 16.0),
    GlassSwitchSize.regular: (w: 36.0, h: 16.0, knobW: 21.0),
    GlassSwitchSize.large: (w: 46.0, h: 21.0, knobW: 27.0),
  };

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    final m = _metrics[size]!;
    const inset = 1.0;
    final knobH = m.h - inset * 2;
    final enabled = onChanged != null;

    final trackOff = t.isDark ? const Color(0x18FFFFFF) : const Color(0x17000000);
    final trackOn = activeColor ?? t.accent;
    final knobColor = value || !t.isDark ? const Color(0xFFFFFFFF) : const Color(0xFFE3E3E3);

    return Semantics(
      toggled: value,
      enabled: enabled,
      child: GlassPressable(
        onPressed: enabled ? () => onChanged!(!value) : null,
        builder: (context, hovered, pressed) {
          // Stretch toward the destination while the pointer is down.
          final stretch = pressed ? m.h * 0.28 : 0.0;
          final knobW = m.knobW + stretch;
          final travel = m.w - inset * 2 - knobW;
          final left = inset + (value ? travel : 0);

          return Opacity(
            opacity: enabled ? 1 : 0.5,
            child: SizedBox(
              width: m.w,
              height: m.h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: value ? trackOn : trackOff,
                        borderRadius: BorderRadius.circular(m.h / 2),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    left: left,
                    top: inset,
                    width: knobW,
                    height: knobH,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: knobColor,
                        borderRadius: BorderRadius.circular(knobH / 2),
                        border: t.isDark
                            ? null
                            : Border.all(color: const Color(0x0F000000), width: 0.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 1.5,
                            offset: Offset(0, 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The circled "i" button shown next to switches in System Settings.
class GlassInfoButton extends StatelessWidget {
  const GlassInfoButton({super.key, required this.onPressed, this.size = 18});

  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return GlassPressable(
      onPressed: onPressed,
      builder: (context, hovered, pressed) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hovered ? t.label : t.secondaryLabel,
            width: 1.1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'i',
          style: TextStyle(
            fontFamily: kGlassFontFamily,
            fontSize: size * 0.62,
            height: 1,
            fontWeight: FontWeight.w600,
            color: hovered ? t.label : t.secondaryLabel,
          ),
        ),
      ),
    );
  }
}
