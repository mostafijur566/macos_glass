import 'package:flutter/widgets.dart';

/// San Francisco, the macOS system font.
const kGlassFontFamily = '.AppleSystemUIFont';

/// Colors and text styles for the macOS 26/27 ("Liquid Glass") look:
/// grouped rounded sections on a calm canvas, translucent glass chrome,
/// capsule controls and the system accent color.
@immutable
class GlassThemeData {
  const GlassThemeData._({
    required this.brightness,
    required this.accent,
    required this.canvas,
    required this.sidebarTint,
    required this.card,
    required this.cardBorder,
    required this.divider,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.controlFill,
    required this.controlFillHover,
    required this.controlFillPressed,
    required this.fieldFill,
    required this.fieldBorder,
    required this.glassTint,
    required this.glassBorder,
    required this.glassHighlight,
    required this.menuTint,
    required this.hover,
    required this.shadow,
    required this.destructive,
    required this.success,
    required this.warning,
  });

  factory GlassThemeData.light({Color accent = const Color(0xFF007AFF)}) {
    return GlassThemeData._(
      brightness: Brightness.light,
      accent: accent,
      canvas: const Color(0xFFF2F2F4),
      sidebarTint: const Color(0x66FFFFFF),
      card: const Color(0xFFFFFFFF),
      cardBorder: const Color(0x0F000000),
      divider: const Color(0x14000000),
      label: const Color(0xE6000000),
      secondaryLabel: const Color(0x85000000),
      tertiaryLabel: const Color(0x47000000),
      controlFill: const Color(0x0F000000),
      controlFillHover: const Color(0x17000000),
      controlFillPressed: const Color(0x24000000),
      fieldFill: const Color(0xFFFFFFFF),
      fieldBorder: const Color(0x1F000000),
      glassTint: const Color(0xB3FFFFFF),
      glassBorder: const Color(0x1A000000),
      glassHighlight: const Color(0xCCFFFFFF),
      menuTint: const Color(0xD9F6F6F6),
      hover: const Color(0x0D000000),
      shadow: const Color(0x26000000),
      destructive: const Color(0xFFFF3B30),
      success: const Color(0xFF28A745),
      warning: const Color(0xFFFF9500),
    );
  }

  factory GlassThemeData.dark({Color accent = const Color(0xFF0A84FF)}) {
    return GlassThemeData._(
      brightness: Brightness.dark,
      accent: accent,
      canvas: const Color(0xFF232323),
      sidebarTint: const Color(0x14FFFFFF),
      card: const Color(0xFF2C2C2D),
      cardBorder: const Color(0x0FFFFFFF),
      divider: const Color(0x14FFFFFF),
      label: const Color(0xF2FFFFFF),
      secondaryLabel: const Color(0x8CFFFFFF),
      tertiaryLabel: const Color(0x52FFFFFF),
      controlFill: const Color(0x24FFFFFF),
      controlFillHover: const Color(0x2EFFFFFF),
      controlFillPressed: const Color(0x3DFFFFFF),
      fieldFill: const Color(0x33000000),
      fieldBorder: const Color(0x1FFFFFFF),
      glassTint: const Color(0x2EFFFFFF),
      glassBorder: const Color(0x24FFFFFF),
      glassHighlight: const Color(0x33FFFFFF),
      menuTint: const Color(0xD92A2A2C),
      hover: const Color(0x12FFFFFF),
      shadow: const Color(0x66000000),
      destructive: const Color(0xFFFF453A),
      success: const Color(0xFF32D74B),
      warning: const Color(0xFFFF9F0A),
    );
  }

  final Brightness brightness;
  final Color accent;

  /// Content area background.
  final Color canvas;

  /// Tint laid over the native sidebar blur.
  final Color sidebarTint;

  /// Grouped section ("form group") background.
  final Color card;
  final Color cardBorder;
  final Color divider;

  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;

  /// Fill of plain (non-accent) buttons and popups.
  final Color controlFill;
  final Color controlFillHover;
  final Color controlFillPressed;

  final Color fieldFill;
  final Color fieldBorder;

  /// Liquid-glass chrome (toolbar capsules, menus, sheets).
  final Color glassTint;
  final Color glassBorder;
  final Color glassHighlight;
  final Color menuTint;

  final Color hover;
  final Color shadow;
  final Color destructive;
  final Color success;
  final Color warning;

  bool get isDark => brightness == Brightness.dark;

  /// Text on top of the accent color.
  Color get onAccent => const Color(0xFFFFFFFF);

  TextStyle _t(double size, FontWeight weight, Color color, {double? height}) =>
      TextStyle(
        fontFamily: kGlassFontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: size >= 20 ? -0.4 : (size >= 15 ? -0.2 : 0),
      );

  /// Window/page title (e.g. "Keyboard").
  TextStyle get title => _t(15, FontWeight.w700, label);

  /// Large page heading.
  TextStyle get largeTitle => _t(22, FontWeight.w700, label);

  /// Section heading above a group ("Text Input").
  TextStyle get sectionTitle => _t(13, FontWeight.w700, label);

  TextStyle get headline => _t(13, FontWeight.w600, label);
  TextStyle get body => _t(13, FontWeight.w400, label, height: 1.25);
  TextStyle get callout => _t(12, FontWeight.w400, label);
  TextStyle get caption => _t(11, FontWeight.w400, secondaryLabel, height: 1.3);

  GlassThemeData copyWith({Color? accent}) => isDark
      ? GlassThemeData.dark(accent: accent ?? this.accent)
      : GlassThemeData.light(accent: accent ?? this.accent);

  @override
  bool operator ==(Object other) =>
      other is GlassThemeData &&
      other.brightness == brightness &&
      other.accent == accent;

  @override
  int get hashCode => Object.hash(brightness, accent);
}

/// Provides [GlassThemeData] to descendants.
class GlassTheme extends InheritedWidget {
  const GlassTheme({super.key, required this.data, required super.child});

  final GlassThemeData data;

  static GlassThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<GlassTheme>();
    if (theme != null) return theme.data;
    final dark = MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    return dark ? GlassThemeData.dark() : GlassThemeData.light();
  }

  @override
  bool updateShouldNotify(GlassTheme oldWidget) => data != oldWidget.data;
}
