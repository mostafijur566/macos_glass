import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'glass.dart';
import 'icons.dart';
import 'theme.dart';

class GlassMenuItem<T> {
  const GlassMenuItem({required this.value, required this.label, this.enabled = true});
  final T value;
  final String label;
  final bool enabled;
}

class _MenuResult<T> {
  const _MenuResult(this.value);
  final T value;
}

/// Shows a glass menu next to [anchor] (global coordinates). Completes with
/// the chosen item, or null when dismissed.
Future<GlassMenuItem<T>?> showGlassMenu<T>(
  BuildContext context, {
  required Rect anchor,
  required List<GlassMenuItem<T>> items,
  T? selected,
  bool hasSelection = false,
  double? minWidth,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final theme = GlassTheme.of(context);
  final completer = Completer<GlassMenuItem<T>?>();
  late OverlayEntry entry;

  void close([_MenuResult<GlassMenuItem<T>>? result]) {
    if (entry.mounted) entry.remove();
    if (!completer.isCompleted) completer.complete(result?.value);
  }

  entry = OverlayEntry(
    builder: (ctx) => GlassTheme(
      data: theme,
      child: _MenuLayer<T>(
        anchor: anchor,
        items: items,
        selected: selected,
        hasSelection: hasSelection,
        minWidth: minWidth ?? anchor.width,
        onSelect: (item) => close(_MenuResult(item)),
        onDismiss: () => close(),
      ),
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

class _MenuLayer<T> extends StatelessWidget {
  const _MenuLayer({
    required this.anchor,
    required this.items,
    required this.selected,
    required this.hasSelection,
    required this.minWidth,
    required this.onSelect,
    required this.onDismiss,
  });

  final Rect anchor;
  final List<GlassMenuItem<T>> items;
  final T? selected;
  final bool hasSelection;
  final double minWidth;
  final ValueChanged<GlassMenuItem<T>> onSelect;
  final VoidCallback onDismiss;

  static const _itemHeight = 24.0;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final contentHeight = items.length * _itemHeight + 10;
    final spaceBelow = screen.height - anchor.bottom - 12;
    final spaceAbove = anchor.top - 12;
    final below = spaceBelow >= math.min(contentHeight, 220) || spaceBelow >= spaceAbove;
    final maxHeight = math.max(80.0, math.min(contentHeight, below ? spaceBelow : spaceAbove));
    final width = math.max(minWidth, 160.0);
    final left = math.min(anchor.left, screen.width - width - 8).clamp(8.0, double.infinity);
    final top = below ? anchor.bottom + 4 : anchor.top - 4 - maxHeight;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          onDismiss();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => onDismiss(),
              onSecondaryTapDown: (_) => onDismiss(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: width,
            height: maxHeight,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 110),
              curve: Curves.easeOut,
              builder: (context, s, child) => Opacity(
                opacity: ((s - 0.96) / 0.04).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: s,
                  alignment: below ? Alignment.topCenter : Alignment.bottomCenter,
                  child: child,
                ),
              ),
              child: GlassSurface(
                borderRadius: BorderRadius.circular(12),
                tint: GlassTheme.of(context).menuTint,
                elevation: 2,
                child: ListView(
                  padding: const EdgeInsets.all(5),
                  children: [
                    for (final item in items)
                      _MenuRow<T>(
                        item: item,
                        checked: hasSelection && item.value == selected,
                        showCheckColumn: hasSelection,
                        onTap: item.enabled ? () => onSelect(item) : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow<T> extends StatelessWidget {
  const _MenuRow({
    required this.item,
    required this.checked,
    required this.showCheckColumn,
    required this.onTap,
  });

  final GlassMenuItem<T> item;
  final bool checked;
  final bool showCheckColumn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return GlassPressable(
      onPressed: onTap,
      builder: (context, hovered, pressed) {
        final active = hovered && onTap != null;
        final fg = !item.enabled
            ? t.tertiaryLabel
            : (active ? t.onAccent : t.label);
        return Container(
          height: _MenuLayer._itemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: active ? t.accent : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              if (showCheckColumn)
                SizedBox(
                  width: 18,
                  child: checked ? Icon(GlassIcons.check, size: 11, color: fg) : null,
                ),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.body.copyWith(color: fg),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A pop-up button: shows the current choice and opens a glass menu.
class GlassPopupButton<T> extends StatelessWidget {
  const GlassPopupButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder,
    this.expand = true,
  });

  final T? value;
  final List<GlassMenuItem<T>> items;
  final ValueChanged<T>? onChanged;
  final String? placeholder;

  /// Fill the available width (forms) or size to the text (toolbars).
  final bool expand;

  Future<void> _open(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final picked = await showGlassMenu<T>(
      context,
      anchor: origin & box.size,
      items: items,
      selected: value,
      hasSelection: true,
    );
    if (picked != null) onChanged?.call(picked.value);
  }

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    String? label;
    for (final i in items) {
      if (i.value == value) label = i.label;
    }
    final enabled = onChanged != null;
    return Builder(builder: (context) {
      return GlassPressable(
        onPressed: enabled ? () => _open(context) : null,
        builder: (context, hovered, pressed) {
          final row = Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Flexible(
                fit: expand ? FlexFit.tight : FlexFit.loose,
                child: Text(
                  label ?? placeholder ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.body.copyWith(
                    color: label == null ? t.tertiaryLabel : t.label,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(GlassIcons.chevronUpDown, size: 11, color: t.secondaryLabel),
            ],
          );
          return Opacity(
            opacity: enabled ? 1 : 0.45,
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: pressed
                    ? t.controlFillPressed
                    : (hovered ? t.controlFillHover : t.controlFill),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: t.cardBorder, width: 0.5),
              ),
              child: row,
            ),
          );
        },
      );
    });
  }
}
