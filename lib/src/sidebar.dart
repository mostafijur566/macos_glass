import 'package:flutter/widgets.dart';

import 'glass.dart';
import 'icons.dart';
import 'text_field.dart';
import 'theme.dart';
import 'window.dart';

class GlassSidebarItem {
  const GlassSidebarItem({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF8E8E93),
  });

  final IconData icon;
  final String label;

  /// Colour of the rounded icon tile (System Settings style).
  final Color color;
}

/// System Settings–style sidebar: search field, then items with coloured
/// icon tiles. Typing in the search field filters the items.
class GlassSidebar extends StatefulWidget {
  const GlassSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.searchPlaceholder = 'Search',
    this.header,
    this.footer,
  });

  final List<GlassSidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String? searchPlaceholder;
  final Widget? header;
  final Widget? footer;

  @override
  State<GlassSidebar> createState() => _GlassSidebarState();
}

class _GlassSidebarState extends State<GlassSidebar> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visible = <int>[
      for (var i = 0; i < widget.items.length; i++)
        if (_query.isEmpty ||
            widget.items[i].label.toLowerCase().contains(_query.toLowerCase()))
          i,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Room for the traffic lights.
        const SizedBox(height: kGlassTitlebarHeight),
        if (widget.searchPlaceholder != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: GlassTextField(
              capsule: true,
              placeholder: widget.searchPlaceholder,
              prefixIcon: GlassIcons.search,
              onChanged: (v) => setState(() => _query = v.trim()),
              onSubmitted: (_) {
                if (visible.isNotEmpty) widget.onSelect(visible.first);
              },
            ),
          ),
        if (widget.header != null) widget.header!,
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
            children: [
              for (final i in visible)
                _SidebarRow(
                  item: widget.items[i],
                  selected: i == widget.selectedIndex,
                  onTap: () => widget.onSelect(i),
                ),
            ],
          ),
        ),
        if (widget.footer != null) widget.footer!,
      ],
    );
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({required this.item, required this.selected, required this.onTap});

  final GlassSidebarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GlassPressable(
        onPressed: onTap,
        builder: (context, hovered, pressed) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              // System Settings marks the selection with a neutral grey pill;
              // the label keeps its normal colour.
              color: selected
                  ? (t.isDark ? const Color(0x1FFFFFFF) : const Color(0x14000000))
                  : (hovered ? t.hover : null),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                GlassIconTile(icon: item.icon, color: item.color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.body.copyWith(
                      color: t.label,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// White glyph on a rounded, softly graded colour tile.
class GlassIconTile extends StatelessWidget {
  const GlassIconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 22,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final top = Color.lerp(color, const Color(0xFFFFFFFF), 0.18)!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, color],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 1, offset: Offset(0, 0.5)),
        ],
      ),
      child: Icon(icon, size: size * 0.62, color: const Color(0xFFFFFFFF)),
    );
  }
}
