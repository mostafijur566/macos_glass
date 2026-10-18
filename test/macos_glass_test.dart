import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_glass/macos_glass.dart';

Widget _wrap(Widget child, {GlassThemeMode mode = GlassThemeMode.light}) =>
    GlassApp(themeMode: mode, home: Center(child: child));

void main() {
  testWidgets('GlassSwitch has System Settings metrics and toggles', (tester) async {
    var value = false;
    await tester.pumpWidget(_wrap(StatefulBuilder(
      builder: (context, setState) => GlassSwitch(
        value: value,
        onChanged: (v) => setState(() => value = v),
      ),
    )));
    expect(tester.getSize(find.byType(GlassSwitch)), const Size(36, 16));

    await tester.tap(find.byType(GlassSwitch));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });

  testWidgets('switch sizes', (tester) async {
    for (final (size, expected) in [
      (GlassSwitchSize.mini, const Size(28, 12)),
      (GlassSwitchSize.large, const Size(46, 21)),
    ]) {
      await tester.pumpWidget(_wrap(GlassSwitch(value: true, onChanged: (_) {}, size: size)));
      expect(tester.getSize(find.byType(GlassSwitch)), expected);
    }
  });

  testWidgets('disabled switch ignores taps', (tester) async {
    await tester.pumpWidget(_wrap(const GlassSwitch(value: false, onChanged: null)));
    await tester.tap(find.byType(GlassSwitch));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('GlassPopupButton opens a menu and picks an item', (tester) async {
    String? picked;
    await tester.pumpWidget(_wrap(SizedBox(
      width: 200,
      child: GlassPopupButton<String>(
        value: 'A',
        items: const [
          GlassMenuItem(value: 'A', label: 'Alpha'),
          GlassMenuItem(value: 'B', label: 'Bravo'),
        ],
        onChanged: (v) => picked = v,
      ),
    )));
    expect(find.text('Alpha'), findsOneWidget);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('Bravo'), findsOneWidget);
    await tester.tap(find.text('Bravo'));
    await tester.pumpAndSettle();
    expect(picked, 'B');
  });

  testWidgets('segmented control reports the tapped segment', (tester) async {
    var v = 0;
    await tester.pumpWidget(_wrap(GlassSegmentedControl<int>(
      value: v,
      onChanged: (x) => v = x,
      segments: const [
        GlassSegment(value: 0, label: 'One'),
        GlassSegment(value: 1, label: 'Two'),
      ],
    )));
    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(v, 1);
  });

  testWidgets('GlassApp follows the theme mode', (tester) async {
    late GlassThemeData data;
    await tester.pumpWidget(_wrap(
      Builder(builder: (context) {
        data = GlassTheme.of(context);
        return const SizedBox();
      }),
      mode: GlassThemeMode.dark,
    ));
    expect(data.isDark, isTrue);
  });

  testWidgets('form section renders title and rows', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(
      width: 400,
      child: GlassFormSection(title: 'Text Input', children: [
        GlassFormRow(label: 'Input Sources'),
        GlassFormRow(label: 'Dictation', subtitle: 'Off'),
      ]),
    )));
    expect(find.text('Text Input'), findsOneWidget);
    expect(find.text('Input Sources'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
  });
}
