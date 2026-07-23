import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/design_system/sheet.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/workflow_canvas.dart';
import 'package:autoflow/features/builder/node_palette.dart';
import 'package:autoflow/features/builder/preview_panel.dart';
import 'package:autoflow/features/builder/properties_panel.dart';
import 'package:autoflow/features/builder/top_bar.dart';
import 'package:autoflow/features/builder/variables_panel.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

class BuilderPage extends ConsumerStatefulWidget {
  const BuilderPage({super.key});

  @override
  ConsumerState<BuilderPage> createState() => _BuilderPageState();
}

class _BuilderPageState extends ConsumerState<BuilderPage> {
  String? _lastSheetNodeId;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(workflowProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < AnchorSpacing.mobileBreakpoint;
    final minimal = s.embedConfig.embedChrome == EmbedChrome.minimal;

    ref.listen(workflowProvider, (prev, next) {
      if (!isMobile) return;
      final id = next.selectedId;
      if (id != null &&
          id != _lastSheetNodeId &&
          next.sideTab == SidePanelTab.properties) {
        _lastSheetNodeId = id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showAnchorSheet(
            context: context,
            child: PropertiesPanel(
              onClose: () {
                Navigator.of(context).maybePop();
                ref.read(workflowProvider.notifier).select(null);
              },
            ),
          ).whenComplete(() => _lastSheetNodeId = null);
        });
      }
      if (id == null) _lastSheetNodeId = null;
    });

    Widget? side;
    if (!isMobile) {
      side = switch (s.sideTab) {
        SidePanelTab.variables => const VariablesPanel(),
        SidePanelTab.preview => const PreviewPanel(),
        SidePanelTab.properties =>
          s.selectedNode != null ? const PropertiesPanel() : null,
      };
    }

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AnchorColors.gradientPage),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Elevated so canvas overflow never paints over the bar.
            Material(
              elevation: 2,
              color: Colors.transparent,
              child: BuilderTopBar(
                minimal: minimal,
                onOpenPalette: isMobile
                    ? () {
                        showAnchorSheet(
                          context: context,
                          child: NodePalette(
                            onClose: () => Navigator.of(context).maybePop(),
                          ),
                        );
                      }
                    : null,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  if (!isMobile && !minimal)
                    Material(
                      elevation: 1,
                      color: Colors.transparent,
                      child: const NodePalette(),
                    ),
                  const Expanded(child: WorkflowCanvas()),
                  if (side != null)
                    Material(
                      elevation: 1,
                      color: Colors.transparent,
                      child: side,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
