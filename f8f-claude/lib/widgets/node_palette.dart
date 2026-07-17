import 'package:flutter/material.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/icons/lucide_path_icon.dart';
import 'package:flowstock/widgets/shared_widgets.dart';

class NodePalette extends StatelessWidget {
  const NodePalette({super.key, required this.controller});

  final FlowController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.chromeTick,
      builder: (context, _) {
        final open = controller.paletteOpen;
        final q = controller.query.toLowerCase();
        final groups = NodeCatalog.groups
            .map((g) {
              final items = g.items.where((t) {
                if (q.isEmpty) return true;
                final def = NodeCatalog.typeOf(t);
                return def.name.toLowerCase().contains(q) ||
                    def.description.toLowerCase().contains(q);
              }).toList();
              return (label: g.label, items: items);
            })
            .where((g) => g.items.isNotEmpty)
            .toList();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          width: open ? 236 : 0,
          decoration: BoxDecoration(
            color: FsColors.white.withValues(alpha: 0.92),
            border: const Border(
              right: BorderSide(color: FsColors.slate200),
            ),
          ),
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: 236,
              maxWidth: 236,
              child: SizedBox(
                width: 236,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: SizedBox(
                        height: 34,
                        child: TextField(
                          onChanged: controller.setQuery,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: FsColors.slate900,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search nodes…',
                            hintStyle: const TextStyle(
                              fontSize: 12.5,
                              color: FsColors.slate400,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 10, right: 6),
                              child: LucidePathIcon(
                                pathData: Ic.search,
                                size: 14,
                                color: FsColors.slate400,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 14,
                            ),
                            filled: true,
                            fillColor: FsColors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: FsColors.slate200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: FsColors.slate200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: FsColors.blue500,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: groups.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No nodes match "${controller.query}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: FsColors.slate400,
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.only(bottom: 8),
                              children: [
                                for (final g in groups) ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      10,
                                      14,
                                      4,
                                    ),
                                    child: Text(
                                      g.label.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.7,
                                        color: FsColors.slate400,
                                      ),
                                    ),
                                  ),
                                  for (final typeId in g.items)
                                    _PaletteItem(
                                      typeId: typeId,
                                      controller: controller,
                                    ),
                                ],
                              ],
                            ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: FsColors.slate200),
                        ),
                      ),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: FsColors.slate400,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: '16 node types · registered via ',
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: controller.openEmbed,
                                child: const Text(
                                  'defineNodes()',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: FsColors.blue600,
                                    fontFamily: 'Consolas',
                                    fontFamilyFallback: [
                                      'Menlo',
                                      'monospace',
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaletteItem extends StatefulWidget {
  const _PaletteItem({required this.typeId, required this.controller});

  final String typeId;
  final FlowController controller;

  @override
  State<_PaletteItem> createState() => _PaletteItemState();
}

class _PaletteItemState extends State<_PaletteItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final def = NodeCatalog.typeOf(widget.typeId);
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onPanStart: (d) {
          widget.controller.startPaletteDrag(widget.typeId, d.globalPosition);
        },
        onPanUpdate: (d) {
          widget.controller.onPointerMove(
            local: Offset.zero,
            global: d.globalPosition,
          );
        },
        onPanEnd: (d) {
          // Drop handled by overlay listener in FlowBuilderPage
        },
        child: Container(
          color: _hover ? FsColors.slate100 : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              ChipDecor(
                category: def.category,
                iconPath: def.iconPath,
                size: 26,
                iconSize: 13,
                radius: 7,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: FsColors.slate900,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      def.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: FsColors.slate400,
                        height: 1.3,
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
