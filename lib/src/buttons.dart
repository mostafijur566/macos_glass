import 'package:flutter/widgets.dart';

import 'glass.dart';
import 'theme.dart';

enum GlassButtonStyle {
  /// Accent-colored capsule — the main action.
  primary,

  /// Grey rounded button used inside content ("Edit…", "Keyboard Shortcuts…").
  bezel,

  /// Translucent glass capsule used in the title bar.
  glass,

  /// Red, for destructive confirmations.
  destructive,

  /// Text only, no background until hovered.
  plain,
}

enum GlassControlSize { small, regular, large }

extension on GlassControlSize {
  double get height => switch (this) {
        GlassControlSize.small => 22,
        GlassControlSize.regular => 28,
        GlassControlSize.large => 34,
      };
  double get fontSize => switch (this) {
        GlassControlSize.small => 11.5,
        GlassControlSize.regular => 13,
        GlassControlSize.large => 14,
      };
  double get hPad => switch (this) {
        GlassControlSize.small => 9,
        GlassControlSize.regular => 13,
        GlassControlSize.large => 18,
      };
}

/// A macOS 26/27 push button.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.style = GlassButtonStyle.bezel,
    this.size = GlassControlSize.regular,
    this.expand = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final GlassButtonStyle style;
  final GlassControlSize size;

  /// Fill the available width (e.g. alert buttons).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    final enabled = onPressed != null;
    final h = size.height;

    return GlassPressable(
      onPressed: onPressed,
      builder: (context, hovered, pressed) {
        final Color fg;
        Color? bg;
        switch (style) {
          case GlassButtonStyle.primary:
            fg = t.onAccent;
            bg = _shade(t.accent, hovered, pressed);
          case GlassButtonStyle.destructive:
            fg = t.onAccent;
            bg = _shade(t.destructive, hovered, pressed);
          case GlassButtonStyle.bezel:
            fg = t.label;
            bg = pressed
                ? t.controlFillPressed
                : (hovered ? t.controlFillHover : t.controlFill);
          case GlassButtonStyle.glass:
            fg = t.label;
            bg = null;
          case GlassButtonStyle.plain:
            fg = t.accent;
            bg = pressed ? t.controlFillPressed : (hovered ? t.hover : null);
        }

        Widget content = Padding(
          padding: EdgeInsets.symmetric(horizontal: size.hPad),
          child: Center(
            widthFactor: expand ? null : 1,
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: kGlassFontFamily,
                fontSize: size.fontSize,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: IconTheme(
                data: IconThemeData(color: fg, size: size.fontSize + 2),
                child: child,
              ),
            ),
          ),
        );

        final radius = BorderRadius.circular(
            style == GlassButtonStyle.bezel ? h * 0.32 : h / 2);
        Widget button;
        if (style == GlassButtonStyle.glass) {
          button = GlassSurface(
            borderRadius: radius,
            tint: pressed
                ? t.controlFillPressed
                : (hovered ? t.controlFillHover : null),
            child: SizedBox(height: h, child: content),
          );
        } else {
          button = Container(
            height: h,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
              border: style == GlassButtonStyle.bezel
                  ? Border.all(color: t.cardBorder, width: 0.5)
                  : null,
              boxShadow: (style == GlassButtonStyle.primary ||
                          style == GlassButtonStyle.destructive) &&
                      enabled
                  ? [
                      BoxShadow(
                        color: (style == GlassButtonStyle.primary
                                ? t.accent
                                : t.destructive)
                            .withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: content,
          );
        }
        return Opacity(opacity: enabled ? 1 : 0.42, child: button);
      },
    );
  }

  static Color _shade(Color c, bool hovered, bool pressed) {
    if (pressed) return Color.lerp(c, const Color(0xFF000000), 0.18)!;
    if (hovered) return Color.lerp(c, const Color(0xFFFFFFFF), 0.08)!;
    return c;
  }
}

/// Round icon button: glass circle in the title bar, or plain in content.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.glass = false,
    this.size = 28,
    this.iconSize,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool glass;
  final double size;
  final double? iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    final enabled = onPressed != null;
    return GlassPressable(
      onPressed: onPressed,
      builder: (context, hovered, pressed) {
        final iconWidget = Icon(
          icon,
          size: iconSize ?? size * 0.5,
          color: color ?? (glass ? t.label : t.secondaryLabel),
        );
        final Widget body;
        if (glass) {
          body = GlassSurface(
            tint: pressed
                ? t.controlFillPressed
                : (hovered ? t.controlFillHover : null),
            child: SizedBox(width: size, height: size, child: Center(child: iconWidget)),
          );
        } else {
          body = Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pressed
                  ? t.controlFillPressed
                  : (hovered ? t.controlFillHover : null),
            ),
            child: Center(child: iconWidget),
          );
        }
        return Opacity(opacity: enabled ? 1 : 0.35, child: body);
      },
    );
  }
}
