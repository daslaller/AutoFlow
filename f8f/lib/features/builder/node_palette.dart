import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/node_card.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

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
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
          child: Text(
            kind.label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: kind.color,
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
      decoration: BoxDecoration(
        color: AnchorColors.sidebarBg,
        border: Border(right: BorderSide(color: AnchorColors.sidebarBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Nodes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: AnchorColors.slate500,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: ctrl.setSearch,
              style: TextStyle(color: AnchorColors.foreground, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search nodes',
                hintStyle: TextStyle(
                  color: AnchorColors.mutedForeground,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: AnchorColors.mutedForeground,
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                isDense: true,
                filled: true,
                fillColor: AnchorColors.slate50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
                  borderSide: BorderSide(color: AnchorColors.sidebarBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
                  borderSide: BorderSide(color: AnchorColors.sidebarBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
                  borderSide: const BorderSide(color: AnchorColors.blue500),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: types.isEmpty
                ? Center(
                    child: Text(
                      'No nodes match',
                      style: TextStyle(
                        color: AnchorColors.mutedForeground,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                    children: children,
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AnchorColors.sidebarBorder)),
            ),
            child: Text(
              'Drag onto the canvas\nG snaps to grid · click a wire to delete',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: AnchorColors.mutedForeground,
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
      childWhenDragging: Opacity(opacity: 0.35, child: _itemBody(c, def)),
      child: _itemBody(c, def),
    );
  }

  Widget _itemBody(Color c, NodeDef def) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(kindIcon(def.kind), size: 14, color: c),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AnchorColors.foreground,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        def.sublabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: AnchorColors.mutedForeground,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
