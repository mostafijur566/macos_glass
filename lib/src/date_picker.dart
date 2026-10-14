import 'package:flutter/widgets.dart';

import 'buttons.dart';
import 'glass.dart';
import 'icons.dart';
import 'theme.dart';

const kGlassMonthNames = ['January','February','March','April','May','June','July','August','September','October','November','December'];
const kGlassWeekdayNames = ['M','T','W','T','F','S','S'];

/// Month calendar like the macOS date picker popover.
class GlassCalendar extends StatefulWidget {
  const GlassCalendar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.monthNames = kGlassMonthNames,
    this.weekdayNames = kGlassWeekdayNames,
    this.firstDayOfWeek = DateTime.monday,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  final List<String> monthNames;

  /// Starting from [firstDayOfWeek].
  final List<String> weekdayNames;
  final int firstDayOfWeek;

  @override
  State<GlassCalendar> createState() => _GlassCalendarState();
}

class _GlassCalendarState extends State<GlassCalendar> {
  late DateTime _month = DateTime(widget.selected.year, widget.selected.month);

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    final today = DateTime.now();
    final first = DateTime(_month.year, _month.month, 1);
    final lead = (first.weekday - widget.firstDayOfWeek + 7) % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final cells = <DateTime?>[
      for (var i = 0; i < lead; i++) null,
      for (var d = 1; d <= daysInMonth; d++) DateTime(_month.year, _month.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SizedBox(width: 6),
            Expanded(
              child: GlassPressable(
                onPressed: () => setState(() => _month = DateTime(today.year, today.month)),
                builder: (context, h, p) => Text(
                  '${widget.monthNames[_month.month - 1]} ${_month.year}',
                  style: t.headline,
                ),
              ),
            ),
            GlassIconButton(icon: GlassIcons.chevronLeft, iconSize: 12, size: 24, onPressed: () => _shift(-1)),
            GlassIconButton(icon: GlassIcons.chevronRight, iconSize: 12, size: 24, onPressed: () => _shift(1)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final w in widget.weekdayNames)
              Expanded(
                child: Center(child: Text(w, style: t.caption.copyWith(fontWeight: FontWeight.w600))),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var r = 0; r < cells.length / 7; r++)
          Row(
            children: [
              for (final day in cells.sublist(r * 7, r * 7 + 7))
                Expanded(
                  child: day == null
                      ? const SizedBox(height: 32)
                      : GlassPressable(
                          onPressed: () => widget.onChanged(day),
                          builder: (context, hovered, pressed) {
                            final sel = same(day, widget.selected);
                            final isToday = same(day, today);
                            return SizedBox(
                              height: 32,
                              child: Center(
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sel ? t.accent : (hovered ? t.hover : null),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${day.day}',
                                    style: t.body.copyWith(
                                      color: sel ? t.onAccent : (isToday ? t.accent : t.label),
                                      fontWeight: sel || isToday ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

/// A field that shows a formatted date and opens a calendar popover.
class GlassDateField extends StatelessWidget {
  const GlassDateField({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.monthNames,
    this.weekdayNames,
  });

  final DateTime value;

  /// The date as the app wants it displayed.
  final String label;
  final ValueChanged<DateTime> onChanged;
  final List<String>? monthNames;
  final List<String>? weekdayNames;

  Future<void> _open(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    final overlay = Overlay.of(context, rootOverlay: true);
    final theme = GlassTheme.of(context);
    late OverlayEntry entry;
    void close() {
      if (entry.mounted) entry.remove();
    }

    entry = OverlayEntry(builder: (ctx) {
      final screen = MediaQuery.of(ctx).size;
      const w = 268.0, h = 290.0;
      final below = anchor.bottom + h + 12 < screen.height;
      final maxLeft = screen.width - w - 8;
      final left = maxLeft < 8 ? 8.0 : anchor.left.clamp(8.0, maxLeft);
      return GlassTheme(
        data: theme,
        child: Stack(children: [
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTapDown: (_) => close()),
          ),
          Positioned(
            left: left,
            top: below ? anchor.bottom + 6 : anchor.top - h - 6,
            width: w,
            child: GlassSurface(
              borderRadius: BorderRadius.circular(16),
              tint: theme.menuTint,
              elevation: 2,
              padding: const EdgeInsets.all(10),
              child: GlassCalendar(
                selected: value,
                monthNames: monthNames ?? kGlassMonthNames,
                weekdayNames: weekdayNames ?? kGlassWeekdayNames,
                onChanged: (d) {
                  close();
                  onChanged(d);
                },
              ),
            ),
          ),
        ]),
      );
    });
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return Builder(
      builder: (context) => GlassPressable(
        onPressed: () => _open(context),
        builder: (context, hovered, pressed) => Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: pressed ? t.controlFillPressed : (hovered ? t.controlFillHover : t.controlFill),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: t.cardBorder, width: 0.5),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: t.body, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Icon(GlassIcons.chevronUpDown, size: 11, color: t.secondaryLabel),
            ],
          ),
        ),
      ),
    );
  }
}
