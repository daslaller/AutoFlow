import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/node_card.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

class NodePalette extends ConsumerWidget {
  const NodePalette({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(workflowProvider);
    final ctrl = ref.read(workflowProvider.notifier);
    final q = s.search.toLowerCase();
    final types = s.catalog.types.where((d) {
      if (q.isEmpty) return true;
      return d.label.toLowerCase().contains(q) ||
          d.sublabel.toLowerCase().contains(q) ||
          d.id.toLowerCase().contains(q);
    }).toList();

    final children = <Widget>[];
    for (final kind in NodeKind.values) {
      final items = types.where((d) => d.kind == kind).toList();
      if (items.isEmpty) continue;
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
          child: Text(
            kind.label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.6,
              color: kind.color.withValues(alpha: 0.75),
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
      for (final def in items) {
        children.add(_PaletteItem(type: def));
      }
    }

    return Container(
      width: AnchorSpacing.sidebarWidth,
      color: AnchorColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 10, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'NODES',
                    style: AnchorTypography.monoSmall.copyWith(
                      color: AnchorColors.sidebarFgMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: AnchorColors.slate400,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: ctrl.setSearch,
              style: const TextStyle(color: AnchorColors.slate200, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search…',
                hintStyle:
                    const TextStyle(color: AnchorColors.slate500, fontSize: 12),
                isDense: true,
                filled: true,
                fillColor: AnchorColors.slate800,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
                  borderSide:
                      const BorderSide(color: AnchorColors.sidebarBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
                  borderSide:
                      const BorderSide(color: AnchorColors.sidebarBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
                  borderSide: const BorderSide(color: AnchorColors.blue500),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: types.isEmpty
                ? const Center(
                    child: Text(
                      'No items match',
                      style: TextStyle(
                        color: AnchorColors.slate500,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                    children: children,
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: AnchorColors.sidebarBorder)),
            ),
            child: Text(
              'Drag to canvas\nG toggles snap\nClick wire to delete',
              style: AnchorTypography.monoSmall.copyWith(
                color: AnchorColors.slate500,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteItem extends StatelessWidget {
  const _PaletteItem({required this.type});

  final NodeTypeDef type;

  @override
  Widget build(BuildContext context) {
    final def = type.asDef;
    final c = def.kind.color;
    return Draggable<NodeDef>(
      data: def,
      feedback: Material(
        color: Colors.transparent,
        child: PaletteGhost(def: def),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: _itemBody(c, def)),
      child: _itemBody(c, def),
    );
  }

  Widget _itemBody(Color c, NodeDef def) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(kindIcon(def.kind), size: 12, color: c),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AnchorColors.slate200,
                  ),
                ),
                Text(
                  def.sublabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AnchorColors.slate500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
