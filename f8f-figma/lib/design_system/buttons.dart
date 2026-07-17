import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

enum AnchorButtonVariant {
  primary,
  gradient,
  outline,
  ghost,
  destructive,
  secondary,
}

enum AnchorButtonSize { sm, md, lg }

class AnchorButton extends StatelessWidget {
  const AnchorButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AnchorButtonVariant.primary,
    this.size = AnchorButtonSize.md,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AnchorButtonVariant variant;
  final AnchorButtonSize size;
  final bool loading;

  EdgeInsets get _padding => switch (size) {
        AnchorButtonSize.sm => const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        AnchorButtonSize.md => const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        AnchorButtonSize.lg => const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      };

  double get _fontSize => switch (size) {
        AnchorButtonSize.sm => 12,
        AnchorButtonSize.md => 13,
        AnchorButtonSize.lg => 14,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        else if (icon != null) ...[
          icon!,
          const SizedBox(width: 7),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    if (variant == AnchorButtonVariant.gradient) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? AnchorColors.gradientBrand : null,
          color: enabled ? null : AnchorColors.slate200,
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
          boxShadow: enabled ? AnchorShadows.sm : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
            child: Padding(
              padding: _padding,
              child: DefaultTextStyle(
                style: TextStyle(
                  color: enabled ? Colors.white : AnchorColors.slate400,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: enabled ? Colors.white : AnchorColors.slate400,
                    size: 14,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final (bg, fg, border) = switch (variant) {
      AnchorButtonVariant.primary => (
          AnchorColors.primary,
          AnchorColors.primaryForeground,
          null as BorderSide?,
        ),
      AnchorButtonVariant.secondary => (
          AnchorColors.secondary,
          AnchorColors.secondaryForeground,
          null,
        ),
      AnchorButtonVariant.outline => (
          Colors.transparent,
          AnchorColors.foreground,
          const BorderSide(color: AnchorColors.border),
        ),
      AnchorButtonVariant.ghost => (
          Colors.transparent,
          AnchorColors.slate600,
          null,
        ),
      AnchorButtonVariant.destructive => (
          Colors.transparent,
          AnchorColors.destructive,
          const BorderSide(color: Color(0xFFFFCDD2)),
        ),
      AnchorButtonVariant.gradient => (
          AnchorColors.primary,
          Colors.white,
          null,
        ),
    };

    return Material(
      color: enabled ? bg : AnchorColors.slate100,
      borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
        hoverColor: variant == AnchorButtonVariant.ghost
            ? AnchorColors.slate100
            : null,
        child: Container(
          padding: _padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
            border: border != null ? Border.fromBorderSide(border) : null,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: enabled ? fg : AnchorColors.slate400,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: enabled ? fg : AnchorColors.slate400,
                size: 14,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AnchorIconButton extends StatelessWidget {
  const AnchorIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AnchorColors.white,
      borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
            border: Border.all(color: AnchorColors.border),
          ),
          child: IconTheme(
            data: const IconThemeData(size: 16, color: AnchorColors.slate600),
            child: icon,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
