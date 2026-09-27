import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A piece of "Liquid Glass": blurs what's behind it, adds a tint, a thin
/// light edge on top and a soft shadow. Used for toolbar capsules, menus,
/// sheets and alerts.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.blur = 24,
    this.tint,
    this.elevation = 1,
    this.padding,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final Color? tint;

  /// 0 = flat, 1 = toolbar capsule, 2 = menu, 3 = sheet/alert.
  final double elevation;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: elevation <= 0
            ? null
            : [
                BoxShadow(
                  color: t.shadow,
                  blurRadius: 6 + elevation * 10,
                  offset: Offset(0, 1 + elevation * 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: tint ?? t.glassTint,
            ),
            child: Container(
              padding: padding,
              // A light sheen on the upper half and a hairline edge give the
              // "glass" depth.
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: t.glassBorder, width: 0.6),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    t.glassHighlight.withValues(alpha: t.glassHighlight.a * 0.5),
                    const Color(0x00FFFFFF),
                  ],
                  stops: const [0, 0.55],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tracks hover / press for custom controls and gives a click cursor.
class GlassPressable extends StatefulWidget {
  const GlassPressable({
    super.key,
    required this.builder,
    this.onPressed,
    this.cursor,
  });

  final Widget Function(BuildContext context, bool hovered, bool pressed) builder;
  final VoidCallback? onPressed;
  final MouseCursor? cursor;

  @override
  State<GlassPressable> createState() => _GlassPressableState();
}

class _GlassPressableState extends State<GlassPressable> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      cursor: enabled
          ? (widget.cursor ?? SystemMouseCursors.basic)
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: widget.onPressed,
        child: widget.builder(context, enabled && _hover, enabled && _down),
      ),
    );
  }
}
