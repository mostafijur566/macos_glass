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
    final radius = BorderRadius.circular(widget.capsule ? 999 : (multiline ? 9 : 8));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: _focused
            ? [BoxShadow(color: t.accent.withValues(alpha: 0.45), spreadRadius: 3)]
            : null,
      ),
      child: CupertinoTextField(
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
        placeholderStyle: t.body.copyWith(color: t.tertiaryLabel),
        padding: EdgeInsets.symmetric(
          horizontal: widget.capsule ? 10 : 9,
          vertical: multiline ? 7 : 5,
        ),
        prefix: widget.prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: 9),
                child: Icon(widget.prefixIcon, size: 13, color: t.secondaryLabel),
              ),
        decoration: BoxDecoration(
          color: widget.capsule ? t.controlFill : t.fieldFill,
          borderRadius: radius,
          border: Border.all(
            color: _focused ? t.accent : t.fieldBorder,
            width: _focused ? 1 : 0.6,
          ),
        ),
      ),
    );
  }
}
