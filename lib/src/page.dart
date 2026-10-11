import 'package:flutter/widgets.dart';

import 'buttons.dart';
import 'icons.dart';
import 'theme.dart';
import 'window.dart';

/// A content page whose title row shares the title bar with the traffic
/// lights, like System Settings: [back] Title ……… [actions].
class GlassPage extends StatelessWidget {
  const GlassPage({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.showBackButton,
  });

  final String title;
  final Widget body;

  /// Usually [GlassButton]s; shown at the right of the title row.
  final List<Widget> actions;

  /// Defaults to "when the surrounding navigator can pop".
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    final canPop = showBackButton ?? Navigator.of(context).canPop();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: kGlassTitlebarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                if (canPop) ...[
                  GlassTitlebarPassthrough(
                    child: GlassIconButton(
                      icon: GlassIcons.chevronLeft,
                      glass: true,
                      size: 30,
                      iconSize: 14,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.title,
                  ),
                ),
                if (actions.isNotEmpty)
                  Flexible(
                    flex: 3,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < actions.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              GlassTitlebarPassthrough(child: actions[i]),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
