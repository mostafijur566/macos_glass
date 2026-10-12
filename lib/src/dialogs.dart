import 'package:flutter/widgets.dart';

import 'buttons.dart';
import 'glass.dart';
import 'theme.dart';

Widget _transition(Animation<double> a, Widget child) {
  final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween(begin: 0.94, end: 1.0).animate(curved),
      child: child,
    ),
  );
}

Future<T?> _showGlassRoute<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = false,
}) {
  final theme = GlassTheme.of(context);
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: const Color(0x38000000),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, _, _) => GlassTheme(data: theme, child: Builder(builder: builder)),
    transitionBuilder: (ctx, a, _, child) => _transition(a, child),
  );
}

/// macOS 26-style alert: icon, bold title, message and capsule buttons.
/// Returns true for the primary button.
Future<bool> showGlassAlert(
  BuildContext context, {
  required String title,
  required String message,
  required String primaryLabel,
  String? secondaryLabel,
  bool destructive = false,
  Widget? icon,
}) async {
  final result = await _showGlassRoute<bool>(
    context,
    builder: (ctx) {
      final t = GlassTheme.of(ctx);
      return Center(
        child: SizedBox(
          width: 280,
          child: GlassSurface(
            borderRadius: BorderRadius.circular(24),
            tint: t.menuTint,
            elevation: 3,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon, const SizedBox(height: 12)],
                Text(title, style: t.headline, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(message,
                    style: t.caption.copyWith(color: t.label, fontSize: 11.5),
                    textAlign: TextAlign.center),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (secondaryLabel != null) ...[
                      Expanded(
                        child: GlassButton(
                          expand: true,
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(secondaryLabel),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: GlassButton(
                        expand: true,
                        style: destructive
                            ? GlassButtonStyle.destructive
                            : GlassButtonStyle.primary,
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(primaryLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// Shows [builder] in a floating glass sheet. [maxWidth] caps the width;
/// the height follows the content up to the window height.
Future<T?> showGlassSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double maxWidth = 560,
  bool barrierDismissible = false,
  bool fillHeight = false,
}) {
  return _showGlassRoute<T>(
    context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      final t = GlassTheme.of(ctx);
      final size = MediaQuery.of(ctx).size;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: size.height - 80,
              minHeight: fillHeight ? size.height - 80 : 0,
            ),
            child: GlassSurface(
              borderRadius: BorderRadius.circular(22),
              tint: t.isDark ? const Color(0xF2262628) : const Color(0xF7F7F7F8),
              elevation: 3,
              child: Builder(builder: builder),
            ),
          ),
        ),
      );
    },
  );
}
