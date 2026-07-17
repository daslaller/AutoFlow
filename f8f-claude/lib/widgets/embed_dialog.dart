import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/icons/lucide_path_icon.dart';
import 'package:flowstock/widgets/shared_widgets.dart';

class EmbedDialog extends StatelessWidget {
  const EmbedDialog({super.key, required this.controller});

  final FlowController controller;

  static const _code = r'''import 'package:flutter/material.dart';
import 'package:flowstock/widgets/flow_builder_page.dart';

class AutomationsScreen extends StatelessWidget {
  const AutomationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowBuilderPage(
      onRun: (graph) async {
        // graph.name, graph.nodes, graph.wires
        await api.post('/automation/execute', graph.toJson());
      },
    );
  }
}''';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.chromeTick,
      builder: (context, _) {
        if (!controller.embedOpen) return const SizedBox.shrink();
        return Positioned.fill(
          child: GestureDetector(
            onTap: controller.closeEmbed,
            child: Container(
              color: FsColors.slate900.withValues(alpha: 0.5),
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 560,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width - 48,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FsColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: FsColors.shadowXl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Embed this builder',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: FsColors.slate900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'FlowBuilderPage is a reusable Flutter widget. Pass onRun to execute the graph — the node library is built from the catalog (defineNodes / your API).',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: FsColors.slate500,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          HoverButton(
                            onTap: controller.closeEmbed,
                            style: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            hoverStyle: BoxDecoration(
                              color: FsColors.slate100,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: Center(
                                child: LucidePathIcon(
                                  pathData: Ic.x,
                                  size: 14,
                                  color: FsColors.slate400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: FsColors.slate900,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const SelectableText(
                              _code,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.7,
                                color: FsColors.slate200,
                                fontFamily: 'Consolas',
                                fontFamilyFallback: ['Menlo', 'monospace'],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: HoverButton(
                              tooltip: 'Copy',
                              onTap: () async {
                                await Clipboard.setData(
                                  const ClipboardData(text: _code),
                                );
                              },
                              style: BoxDecoration(
                                color: FsColors.slate800,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              hoverStyle: BoxDecoration(
                                color: FsColors.slate700,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Copy',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: FsColors.slate200,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '16 node types registered from your catalog · triggers, actions, AI steps and logic controls.',
                        style: TextStyle(
                          fontSize: 11,
                          color: FsColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DragGhost extends StatelessWidget {
  const DragGhost({super.key, required this.controller});

  final FlowController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.viewportTick,
      builder: (context, _) {
        final g = controller.ghost;
        if (g == null) return const SizedBox.shrink();
        final def = NodeCatalog.typeOf(g.type);
        return Positioned(
          left: g.x + 10,
          top: g.y + 8,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.95,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 9, 14, 9),
                decoration: BoxDecoration(
                  color: FsColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.15),
                      offset: const Offset(0, 10),
                      blurRadius: 15,
                      spreadRadius: -3,
                    ),
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChipDecor(
                      category: def.category,
                      iconPath: def.iconPath,
                      size: 26,
                      iconSize: 13,
                      radius: 7,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      def.name,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: FsColors.slate900,
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
