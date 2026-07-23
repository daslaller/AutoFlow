import 'package:flutter/material.dart';

/// Generic hover-decoration wrapper: swaps [style] for [hoverStyle] on
/// pointer enter, for custom-styled buttons that don't want InkWell ripple.
class HoverButton extends StatefulWidget {
  const HoverButton({
    super.key,
    required this.onTap,
    required this.child,
    this.style,
    this.hoverStyle,
    this.tooltip,
  });

  final VoidCallback? onTap;
  final Widget child;
  final BoxDecoration? style;
  final BoxDecoration? hoverStyle;
  final String? tooltip;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final child = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: _hover
              ? (widget.hoverStyle ?? widget.style)
              : widget.style,
          child: widget.child,
        ),
      ),
    );
    if (widget.tooltip == null) return child;
    return Tooltip(message: widget.tooltip!, child: child);
  }
}
