# macos_glass

[![pub package](https://img.shields.io/pub/v/macos_glass.svg)](https://pub.dev/packages/macos_glass)
[![CI](https://github.com/mostafijur566/macos_glass/actions/workflows/ci.yml/badge.svg)](https://github.com/mostafijur566/macos_glass/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Live demo](https://img.shields.io/badge/demo-try%20it%20live-007AFF.svg)](https://mostafijur566.github.io/macos_glass/)

**macOS 26 / 27 ("Liquid Glass") widgets for Flutter desktop apps** — built to look like today's **System Settings**, not the 2020 Big Sur design most macOS packages still follow.

### [▶ Try every widget live in your browser](https://mostafijur566.github.io/macos_glass/)

The demo lets you click through every widget, switch light/dark and accent colours, and copy the Dart code for each example.

![System Settings Sharing pane rebuilt with macos_glass, light mode](https://raw.githubusercontent.com/mostafijur566/macos_glass/main/docs/screenshots/sharing-light.png)

| Pop-up button with a glass menu | Glass alert |
|---|---|
| ![Text fields and a pop-up menu, dark mode](https://raw.githubusercontent.com/mostafijur566/macos_glass/main/docs/screenshots/controls-dark.png) | ![Destructive glass alert, dark mode](https://raw.githubusercontent.com/mostafijur566/macos_glass/main/docs/screenshots/alert-dark.png) |

## Features

- Translucent sidebar with real macOS vibrancy, a search field and coloured icon tiles
- Page title and back button inside the window's title bar, next to the traffic lights
- Grouped, rounded form sections with hairline separators
- Glass toolbar capsules, accent capsules and grey "bezel" buttons
- Switches measured from System Settings (pill-shaped knob, 36 × 16 pt)
- Pop-up buttons with glass menus, segmented control, calendar date picker
- Glass alerts and sheets, tooltips, spinner
- Light and dark themes, custom accent colour
- No Material or Cupertino app required

## Install

```bash
flutter pub add macos_glass
```

or add it to `pubspec.yaml`:

```yaml
dependencies:
  macos_glass: ^0.1.3
```

Minimum: Flutter 3.35 (Dart 3.9), macOS deployment target 10.14.6 (Flutter's default 12.0 is fine).

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

## Run the gallery app

The example app recreates the System Settings **Sharing** pane plus a controls and a dialogs page:

```bash
git clone https://github.com/mostafijur566/macos_glass.git
cd macos_glass/example
flutter create --platforms=macos .
flutter run -d macos
```

## Widgets

Each widget links to its page in the [live demo](https://mostafijur566.github.io/macos_glass/), which has a working example and the code for it.

| Area | Widgets |
|---|---|
| App & window | [`GlassApp`](https://mostafijur566.github.io/macos_glass/#/theme), [`GlassWindowConfig`](https://mostafijur566.github.io/macos_glass/#/window), [`GlassWindow`](https://mostafijur566.github.io/macos_glass/#/window), [`GlassTitlebarPassthrough`](https://mostafijur566.github.io/macos_glass/#/window) |
| Navigation | [`GlassSidebar`](https://mostafijur566.github.io/macos_glass/#/window), `GlassSidebarItem`, [`GlassIconTile`](https://mostafijur566.github.io/macos_glass/#/forms), [`GlassPage`](https://mostafijur566.github.io/macos_glass/#/window) |
| Forms | [`GlassFormSection`, `GlassFormRow`, `GlassGroup`](https://mostafijur566.github.io/macos_glass/#/forms) |
| Buttons | [`GlassButton`](https://mostafijur566.github.io/macos_glass/#/buttons) — `primary`, `bezel`, `glass`, `destructive`, `plain` × `small`/`regular`/`large`; `GlassIconButton`, `GlassInfoButton` |
| Inputs | [`GlassTextField`, `GlassPopupButton`, `GlassSegmentedControl`, `GlassDateField`, `GlassCalendar`](https://mostafijur566.github.io/macos_glass/#/inputs), [`GlassSwitch`](https://mostafijur566.github.io/macos_glass/#/switches) (`mini`/`regular`/`large`) |
| Overlays | [`showGlassMenu`](https://mostafijur566.github.io/macos_glass/#/menus), [`showGlassAlert`, `showGlassSheet`](https://mostafijur566.github.io/macos_glass/#/dialogs), [`GlassTooltip`](https://mostafijur566.github.io/macos_glass/#/feedback) |
| Feedback | [`GlassSpinner`](https://mostafijur566.github.io/macos_glass/#/feedback) |
| Building blocks | [`GlassSurface`, `GlassPressable`](https://mostafijur566.github.io/macos_glass/#/glass), [`GlassTheme`, `GlassThemeData`](https://mostafijur566.github.io/macos_glass/#/theme), `GlassIcons` |

Full API: [pub.dev/documentation/macos_glass](https://pub.dev/documentation/macos_glass/latest/).

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
