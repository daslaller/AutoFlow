import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

class AnchorInput extends StatefulWidget {
  const AnchorInput({
    super.key,
    this.value,
    this.onChanged,
    this.placeholder,
    this.mono = false,
    this.maxLines = 1,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final bool mono;
  final int maxLines;
  final bool enabled;

  @override
  State<AnchorInput> createState() => _AnchorInputState();
}

class _AnchorInputState extends State<AnchorInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant AnchorInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null &&
        widget.value != _controller.text &&
        widget.value != oldWidget.value) {
      _controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      style: (widget.mono
              ? AnchorTypography.mono
              : Theme.of(context).textTheme.bodySmall)
          ?.copyWith(color: AnchorColors.slate700, fontSize: 12),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        isDense: true,
        filled: true,
        fillColor: AnchorColors.slate50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
          borderSide: BorderSide(color: AnchorColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
          borderSide: BorderSide(color: AnchorColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
          borderSide: BorderSide(color: AnchorColors.ring, width: 1.5),
        ),
      ),
    );
  }
}
