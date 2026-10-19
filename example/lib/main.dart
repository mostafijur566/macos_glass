import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:macos_glass/macos_glass.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await const GlassWindowConfig(minSize: Size(720, 520)).apply();
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassApp(title: 'macos_glass', home: _Home());
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _index = 0;

  static const _items = [
    GlassSidebarItem(icon: CupertinoIcons.share, label: 'Sharing', color: Color(0xFF8E8E93)),
    GlassSidebarItem(icon: CupertinoIcons.slider_horizontal_3, label: 'Controls', color: Color(0xFF0A84FF)),
    GlassSidebarItem(icon: CupertinoIcons.square_stack_3d_up, label: 'Dialogs', color: Color(0xFFBF5AF2)),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassWindow(
      sidebar: GlassSidebar(
        items: _items,
        selectedIndex: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
      child: IndexedStack(
        index: _index,
        children: const [_SharingPage(), _ControlsPage(), _DialogsPage()],
      ),
    );
  }
}

// ----------------------------------------------------------------- Sharing

class _SharingPage extends StatefulWidget {
  const _SharingPage();

  @override
  State<_SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends State<_SharingPage> {
  final _on = <String, bool>{'Screen Sharing': true};

  Widget _row(String label, IconData icon, Color color) => GlassFormRow(
        leading: GlassIconTile(icon: icon, color: color, size: 26),
        label: label,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassSwitch(
              value: _on[label] ?? false,
              onChanged: (v) => setState(() => _on[label] = v),
            ),
            const SizedBox(width: 12),
            GlassInfoButton(onPressed: () {}),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Sharing',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GlassFormSection(title: 'Content & Media', children: [
            _row('File Sharing', CupertinoIcons.folder_fill, const Color(0xFF32ADE6)),
            _row('Media Sharing', CupertinoIcons.music_note_list, const Color(0xFFFF9F0A)),
            _row('Screen Sharing', CupertinoIcons.rectangle_on_rectangle, const Color(0xFF5E5CE6)),
            _row('Content Caching', CupertinoIcons.arrow_down_circle, const Color(0xFF8E8E93)),
          ]),
          const SizedBox(height: 24),
          GlassFormSection(title: 'Accessories & Internet', children: [
            _row('Bluetooth Sharing', CupertinoIcons.bluetooth, const Color(0xFF0A84FF)),
            _row('Printer Sharing', CupertinoIcons.printer_fill, const Color(0xFF8E8E93)),
            _row('Internet Sharing', CupertinoIcons.globe, const Color(0xFF0A84FF)),
          ]),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- Controls

class _ControlsPage extends StatefulWidget {
  const _ControlsPage();

  @override
  State<_ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<_ControlsPage> {
  String _fn = 'Do Nothing';
  int _segment = 0;
  bool _nav = false;
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final d = _date;
    return GlassPage(
      title: 'Controls',
      actions: [
        GlassButton(style: GlassButtonStyle.glass, onPressed: () {}, child: const Text('Share')),
        GlassButton(style: GlassButtonStyle.primary, onPressed: () {}, child: const Text('Save')),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GlassFormSection(children: [
            GlassFormRow(
              label: 'Press fn key to',
              trailing: SizedBox(
                width: 180,
                child: GlassPopupButton<String>(
                  value: _fn,
                  items: const [
                    GlassMenuItem(value: 'Do Nothing', label: 'Do Nothing'),
                    GlassMenuItem(value: 'Change Input Source', label: 'Change Input Source'),
                    GlassMenuItem(value: 'Show Emoji & Symbols', label: 'Show Emoji & Symbols'),
                    GlassMenuItem(value: 'Start Dictation', label: 'Start Dictation'),
                  ],
                  onChanged: (v) => setState(() => _fn = v),
                ),
              ),
            ),
            GlassFormRow(
              label: 'Keyboard navigation',
              subtitle: 'Use keyboard navigation to move focus between controls.',
              trailing: GlassSwitch(value: _nav, onChanged: (v) => setState(() => _nav = v)),
            ),
            GlassFormRow(
              label: 'Appearance',
              trailing: GlassSegmentedControl<int>(
                value: _segment,
                onChanged: (v) => setState(() => _segment = v),
                segments: const [
                  GlassSegment(value: 0, label: 'Auto'),
                  GlassSegment(value: 1, label: 'Light'),
                  GlassSegment(value: 2, label: 'Dark'),
                ],
              ),
            ),
            GlassFormRow(
              label: 'Date',
              trailing: SizedBox(
                width: 160,
                child: GlassDateField(
                  value: _date,
                  label: '${d.day} ${kGlassMonthNames[d.month - 1].substring(0, 3)} ${d.year}',
                  onChanged: (v) => setState(() => _date = v),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          GlassFormSection(title: 'Text Input', children: [
            GlassFormRow(
              label: 'Input Sources',
              trailing: GlassButton(onPressed: () {}, child: const Text('Edit…')),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: GlassTextField(placeholder: 'Type something…'),
            ),
          ]),
          const SizedBox(height: 24),
          GlassFormSection(title: 'Switch sizes', children: [
            for (final s in GlassSwitchSize.values)
              GlassFormRow(
                label: s.name,
                trailing: GlassSwitch(size: s, value: _nav, onChanged: (v) => setState(() => _nav = v)),
              ),
          ]),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- Dialogs

class _DialogsPage extends StatelessWidget {
  const _DialogsPage();

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Dialogs',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GlassFormSection(children: [
            GlassFormRow(
              label: 'Alert',
              trailing: GlassButton(
                onPressed: () => showGlassAlert(
                  context,
                  title: 'Delete “Invoice 42”?',
                  message: 'This item will be deleted immediately. You can’t undo this action.',
                  primaryLabel: 'Delete',
                  secondaryLabel: 'Cancel',
                  destructive: true,
                  icon: const GlassIconTile(icon: CupertinoIcons.trash, color: Color(0xFFFF453A), size: 44),
                ),
                child: const Text('Show alert'),
              ),
            ),
            GlassFormRow(
              label: 'Sheet',
              trailing: GlassButton(
                onPressed: () => showGlassSheet<void>(
                  context,
                  maxWidth: 420,
                  builder: (ctx) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('New Folder', style: GlassTheme.of(ctx).title),
                        const SizedBox(height: 14),
                        const GlassTextField(placeholder: 'Name', autofocus: true),
                        const SizedBox(height: 18),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          GlassButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                          const SizedBox(width: 8),
                          GlassButton(
                            style: GlassButtonStyle.primary,
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Create'),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                child: const Text('Show sheet'),
              ),
            ),
            GlassFormRow(
              label: 'Tooltip',
              trailing: GlassTooltip(
                message: 'Hello from macos_glass',
                child: GlassIconButton(icon: CupertinoIcons.question_circle, onPressed: () {}),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
