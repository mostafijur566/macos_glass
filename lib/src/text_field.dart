import 'package:flutter/cupertino.dart' show CupertinoTextField;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Rounded text field with the macOS focus ring.
class GlassTextField extends StatefulWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.prefixIcon,
    this.capsule = false,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final bool enabled;
  final IconData? prefixIcon;

  /// Fully rounded, like the sidebar search field.
  final bool capsule;
  final bool autofocus;

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = GlassTheme.of(context);
    final multiline = widget.maxLines == null || (widget.maxLines ?? 1) > 1;
    // The sidebar search field is a rounded rect (not a full capsule) with
    // a faint fill, like System Settings.
    final r = widget.capsule ? 10.0 : (multiline ? 9.0 : 8.0);
    final radius = BorderRadius.circular(r);
    final fill = widget.capsule
        ? (t.isDark ? const Color(0x14FFFFFF) : const Color(0x0D000000))
        : t.fieldFill;
    final field = CupertinoTextField(
      controller: widget.controller,
      focusNode: _focus,
      autofocus: widget.autofocus,
      placeholder: widget.placeholder,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textAlign: widget.textAlign,
      enabled: widget.enabled,
      cursorColor: t.accent,
      cursorWidth: 1.5,
      style: t.body,
      placeholderStyle: t.body.copyWith(
        color: widget.capsule ? t.secondaryLabel : t.tertiaryLabel,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: widget.capsule ? 6 : 9,
        vertical: multiline ? 7 : (widget.capsule ? 6 : 5),
      ),
      prefix: widget.prefixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: Icon(widget.prefixIcon, size: 14, color: t.secondaryLabel),
            ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: t.fieldBorder, width: 0.6),
      ),
    );
    // macOS draws the focus ring as a stroke *outside* the field; the field
    // itself keeps its normal fill. (A shadow would bleed through the
    // translucent fill and tint the whole field blue.)
    return Stack(
      clipBehavior: Clip.none,
      children: [
        field,
        Positioned(
          left: -3,
          top: -3,
          right: -3,
          bottom: -3,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _focused ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r + 3),
                  border: Border.all(
                    color: t.accent.withValues(alpha: t.isDark ? 0.75 : 0.55),
                    width: 3.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
