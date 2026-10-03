import 'package:flutter/widgets.dart';

import 'glass.dart';
import 'theme.dart';

class GlassSegment<T> {
  const GlassSegment({required this.value, required this.label});
  final T value;
  final String label;
}

/// macOS segmented control: a recessed capsule track with the selected
/// segment raised.
class GlassSegmentedControl<T> extends StatelessWidget {
  const GlassSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<GlassSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return Container(
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: t.controlFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.cardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in segments)
            GlassPressable(
              onPressed: () => onChanged(s.value),
              builder: (context, hovered, pressed) {
                final selected = s.value == value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? (t.isDark ? const Color(0x47FFFFFF) : const Color(0xFFFFFFFF))
                        : (hovered ? t.hover : null),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selected
                        ? const [
                            BoxShadow(color: Color(0x26000000), blurRadius: 3, offset: Offset(0, 1)),
                          ]
                        : null,
                  ),
                  child: Text(
                    s.label,
                    style: t.callout.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
