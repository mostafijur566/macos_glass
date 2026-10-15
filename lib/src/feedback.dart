import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

import 'glass.dart';
import 'theme.dart';

/// Native-looking spinner.
class GlassSpinner extends StatelessWidget {
  const GlassSpinner({super.key, this.radius = 10});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    return CupertinoActivityIndicator(radius: radius, color: t.secondaryLabel);
  }
}

/// Shows [message] in a small glass bubble after hovering for a moment.
class GlassTooltip extends StatefulWidget {
  const GlassTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  State<GlassTooltip> createState() => _GlassTooltipState();
}

class _GlassTooltipState extends State<GlassTooltip> {
  Timer? _timer;
  OverlayEntry? _entry;

  void _show() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || widget.message.isEmpty) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final theme = GlassTheme.of(context);
    _entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: rect.bottom + 6,
        left: rect.center.dx - 120,
        width: 240,
        child: IgnorePointer(
          child: Center(
            child: GlassTheme(
              data: theme,
              child: GlassSurface(
                borderRadius: BorderRadius.circular(7),
                tint: theme.menuTint,
                elevation: 1,
                blur: 16,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(widget.message, style: theme.caption.copyWith(color: theme.label)),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _hide() {
    _timer?.cancel();
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: 650), _show);
      },
      onExit: (_) => _hide(),
      child: Listener(onPointerDown: (_) => _hide(), child: widget.child),
    );
  }
}
