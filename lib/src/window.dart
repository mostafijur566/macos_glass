import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:macos_window_utils/macos/ns_window_delegate.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:macos_window_utils/widgets/macos_toolbar_passthrough.dart';
import 'package:macos_window_utils/widgets/transparent_macos_sidebar.dart';

import 'theme.dart';

/// Height of the unified title bar: the traffic lights, page title and
/// toolbar buttons all sit in this band.
const double kGlassTitlebarHeight = 52;

bool get _isMacOS => Platform.isMacOS;

/// Configures the native window for the macOS 26/27 look: full-size content
/// (Flutter draws under the title bar), transparent title bar, unified
/// toolbar height and the system blur material.
///
/// Call once in `main()` before `runApp` (no-op on other platforms).
class GlassWindowConfig {
  const GlassWindowConfig({
    this.minSize = const Size(900, 600),
    this.hideToolbarInFullScreen = true,
  });

  final Size minSize;
  final bool hideToolbarInFullScreen;

  Future<void> apply() async {
    if (!_isMacOS) return;
    WidgetsFlutterBinding.ensureInitialized();
    await WindowManipulator.initialize(enableWindowDelegate: true);
    await WindowManipulator.setMaterial(NSVisualEffectViewMaterial.sidebar);
    await WindowManipulator.enableFullSizeContentView();
    await WindowManipulator.makeTitlebarTransparent();
    await WindowManipulator.hideTitle();
    await WindowManipulator.addToolbar();
    await WindowManipulator.setToolbarStyle(
        toolbarStyle: NSWindowToolbarStyle.unified);
    await WindowManipulator.setWindowMinSize(minSize);
    if (hideToolbarInFullScreen) {
      WindowManipulator.addNSWindowDelegate(_FullScreenDelegate());
    }
  }
}

class _FullScreenDelegate extends NSWindowDelegate {
  @override
  void windowWillEnterFullScreen() {
    WindowManipulator.removeToolbar();
    super.windowWillEnterFullScreen();
  }

  @override
  void windowDidExitFullScreen() {
    WindowManipulator.addToolbar();
    WindowManipulator.setToolbarStyle(toolbarStyle: NSWindowToolbarStyle.unified);
    super.windowDidExitFullScreen();
  }
}

/// Lets clicks reach Flutter widgets placed in the title bar band
/// (otherwise the native toolbar would treat them as window drags).
class GlassTitlebarPassthrough extends StatelessWidget {
  const GlassTitlebarPassthrough({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _isMacOS ? MacosToolbarPassthrough(child: child) : child;
}

/// The main window: a translucent sidebar (native blur) and an opaque
/// content area.
class GlassWindow extends StatelessWidget {
  const GlassWindow({
    super.key,
    required this.sidebar,
    required this.child,
    this.sidebarWidth = 240,
  });

  final Widget sidebar;
  final Widget child;
  final double sidebarWidth;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    final sidebarPanel = DecoratedBox(
      decoration: BoxDecoration(
        // On macOS the native blur shows through this tint; elsewhere
        // (preview builds) a solid colour stands in for it.
        color: _isMacOS
            ? t.sidebarTint
            : Color.lerp(t.canvas, t.isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF), 0.25),
        border: Border(right: BorderSide(color: t.divider, width: 0.5)),
      ),
      child: sidebar,
    );

    Widget body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: sidebarWidth,
          child: _isMacOS
              ? TransparentMacOSSidebar(child: sidebarPanel)
              : sidebarPanel,
        ),
        Expanded(child: ColoredBox(color: t.canvas, child: child)),
      ],
    );
    if (_isMacOS) body = MacosToolbarPassthroughScope(child: body);
    return body;
  }
}
