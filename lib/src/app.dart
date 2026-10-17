import 'package:flutter/widgets.dart';

import 'theme.dart';

enum GlassThemeMode { system, light, dark }

/// App root for macos_glass apps (no Material or Cupertino app needed).
class GlassApp extends StatelessWidget {
  const GlassApp({
    super.key,
    required this.home,
    this.title = '',
    this.themeMode = GlassThemeMode.system,
    this.accent,
    this.locale,
    this.supportedLocales = const [Locale('en')],
    this.localizationsDelegates,
    this.debugShowCheckedModeBanner = false,
    this.navigatorKey,
  });

  final Widget home;
  final String title;
  final GlassThemeMode themeMode;

  /// Overrides the system blue.
  final Color? accent;
  final Locale? locale;
  final Iterable<Locale> supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final bool debugShowCheckedModeBanner;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      navigatorKey: navigatorKey,
      title: title,
      color: accent ?? const Color(0xFF007AFF),
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      home: home,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, _, _) => builder(context),
          ),
      builder: (context, child) {
        final platformDark =
            MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final dark = switch (themeMode) {
          GlassThemeMode.system => platformDark,
          GlassThemeMode.light => false,
          GlassThemeMode.dark => true,
        };
        final data = dark
            ? GlassThemeData.dark(accent: accent ?? const Color(0xFF0A84FF))
            : GlassThemeData.light(accent: accent ?? const Color(0xFF007AFF));
        return GlassTheme(
          data: data,
          child: DefaultTextStyle(
            style: data.body,
            child: IconTheme(
              data: IconThemeData(color: data.label, size: 16),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
