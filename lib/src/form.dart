import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A rounded group like the boxes in System Settings. Children are separated
/// by hairline dividers.
class GlassGroup extends StatelessWidget {
  const GlassGroup({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.dividers = true,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final bool dividers;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.cardBorder, width: 0.5),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0 && dividers) Container(height: 0.5, color: t.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A heading followed by a [GlassGroup] ("Text Input", "Dictation" …).
class GlassFormSection extends StatelessWidget {
  const GlassFormSection({
    super.key,
    this.title,
    required this.children,
    this.trailing,
    this.footer,
    this.dividers = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  });

  final String? title;
  final Widget? trailing;
  final List<Widget> children;
  final String? footer;
  final bool dividers;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || trailing != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 4, 8),
            child: Row(
              children: [
                Expanded(child: Text(title ?? '', style: t.sectionTitle)),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        GlassGroup(padding: padding, dividers: dividers, children: children),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
            child: Text(footer!, style: t.caption),
          ),
      ],
    );
  }
}

/// One line of a settings group: label (and optional description) on the
/// left, a control on the right.
class GlassFormRow extends StatelessWidget {
  const GlassFormRow({
    super.key,
    required this.label,
    this.subtitle,
    this.trailing,
    this.leading,
  });

  final String label;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: t.body),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: t.caption),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}
