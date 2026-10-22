# macos_glass

[![CI](https://github.com/mostafijur566/macos_glass/actions/workflows/ci.yml/badge.svg)](https://github.com/mostafijur566/macos_glass/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**macOS 26 / 27 ("Liquid Glass") widgets for Flutter desktop apps** — built to look like today's **System Settings**, not the 2020 Big Sur design most macOS packages still follow.

- Translucent sidebar with real macOS vibrancy, a search field and coloured icon tiles
- Page title and back button inside the window's title bar, next to the traffic lights
- Grouped, rounded form sections with hairline separators
- Glass toolbar capsules, accent capsules and grey "bezel" buttons
- Switches measured from System Settings (pill-shaped knob, 36 × 16 pt)
- Pop-up buttons with glass menus, segmented control, calendar date picker
- Glass alerts and sheets, tooltips, spinner
- Light and dark themes, custom accent colour
- No Material or Cupertino app required

<!-- Add screenshots: docs/screenshots/sharing-dark.png, docs/screenshots/controls-light.png -->

## Install

From GitHub:

```yaml
dependencies:
  macos_glass:
    git:
      url: https://github.com/mostafijur566/macos_glass.git
      ref: v0.1.1
```

Minimum: Flutter 3.38, macOS deployment target 10.14.6 (Flutter's default 12.0 is fine).

## Quick start

```dart
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:macos_glass/macos_glass.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Full-size content view, transparent unified title bar, sidebar vibrancy.
  await const GlassWindowConfig(minSize: Size(900, 600)).apply();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassApp(
      title: 'My App',
      home: GlassWindow(
        sidebar: GlassSidebar(
          selectedIndex: 0,
          onSelect: (i) {},
          items: const [
            GlassSidebarItem(icon: CupertinoIcons.share, label: 'Sharing'),
          ],
        ),
        child: GlassPage(
          title: 'Sharing',
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GlassFormSection(title: 'Content & Media', children: [
                GlassFormRow(
                  leading: const GlassIconTile(
                    icon: CupertinoIcons.folder_fill,
                    color: Color(0xFF32ADE6),
                    size: 26,
                  ),
                  label: 'File Sharing',
                  trailing: GlassSwitch(value: false, onChanged: (_) {}),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
```

Run the gallery (it recreates the System Settings **Sharing** pane plus a controls and dialogs page):

```bash
cd example
flutter create --platforms=macos .
flutter run -d macos
```

## Widgets

| Area | Widgets |
|---|---|
| App & window | `GlassApp`, `GlassWindowConfig`, `GlassWindow`, `GlassTitlebarPassthrough` |
| Navigation | `GlassSidebar`, `GlassSidebarItem`, `GlassIconTile`, `GlassPage` |
| Forms | `GlassFormSection`, `GlassFormRow`, `GlassGroup` |
| Buttons | `GlassButton` — `primary`, `bezel`, `glass`, `destructive`, `plain` × `small`/`regular`/`large`; `GlassIconButton`, `GlassInfoButton` |
| Inputs | `GlassTextField`, `GlassPopupButton`, `GlassSegmentedControl`, `GlassSwitch` (`mini`/`regular`/`large`), `GlassDateField`, `GlassCalendar` |
| Overlays | `showGlassMenu`, `showGlassAlert`, `showGlassSheet`, `GlassTooltip` |
| Feedback | `GlassSpinner` |
| Building blocks | `GlassSurface`, `GlassPressable`, `GlassTheme`, `GlassThemeData`, `GlassIcons` |

## How it works

- **Window.** `GlassWindowConfig.apply()` (macOS only; a no-op elsewhere) uses [macos_window_utils](https://pub.dev/packages/macos_window_utils) to enable the full-size content view, make the title bar transparent, add a unified toolbar and set the window material to the sidebar blur. The top 52 pt (`kGlassTitlebarHeight`) is the title bar band.
- **Title bar controls.** `GlassPage` draws its back button, title and actions in that band. Interactive widgets there are wrapped in `GlassTitlebarPassthrough`, so clicks reach Flutter while empty space still drags and zooms the window. Wrap your own title-bar widgets the same way.
- **Sidebar.** Real `NSVisualEffectView` vibrancy behind a light tint; the content area is opaque, like System Settings.
- **Glass.** `GlassSurface` = backdrop blur + tint + top sheen + hairline edge + soft shadow; used by toolbar capsules, menus, sheets and alerts.
- **Theme.** `GlassApp(themeMode:, accent:)` provides `GlassThemeData.light()` / `.dark()`. Read colours and text styles anywhere with `GlassTheme.of(context)`.

## Roadmap

- Toolbar search field and sidebar sections/headers
- Sliders with tick marks, steppers, checkboxes and radio groups
- Tables with sortable columns
- Native `NSMenu` context menus

Issues and pull requests are welcome.

## License

MIT © 2026 Mostafijur Rahman
