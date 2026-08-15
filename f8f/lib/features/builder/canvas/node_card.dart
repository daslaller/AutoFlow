import 'package:flutter/material.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

IconData kindIcon(NodeKind kind) => switch (kind) {
      NodeKind.trigger => Icons.bolt_rounded,
      NodeKind.action => Icons.play_arrow_rounded,
      NodeKind.condition => Icons.call_split_rounded,
      NodeKind.transform => Icons.shuffle_rounded,
      NodeKind.output => Icons.logout_rounded,
    };

/// Drag feedback from the palette. Canvas nodes themselves are HeidNodes
/// widgets (`AutoflowNodeWidget`), not this card.
class PaletteGhost extends StatelessWidget {
  const PaletteGhost({super.key, required this.def});

  final NodeDef def;

  @override
  Widget build(BuildContext context) {
    final c = def.kind.color;
    return Opacity(
      opacity: 0.92,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
        child: Container(
          width: AnchorSpacing.nodeWidth,
          height: AnchorSpacing.nodeHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AnchorColors.white,
            borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
            border: Border.all(color: c.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(kindIcon(def.kind), size: 16, color: c),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AnchorColors.foreground,
                      ),
                    ),
                    Text(
                      def.sublabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AnchorColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
