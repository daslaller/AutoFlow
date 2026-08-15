import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/preview_panel.dart';
import 'package:autoflow/features/builder/properties_panel.dart';
import 'package:autoflow/features/builder/records_panel.dart';
import 'package:autoflow/features/builder/variables_panel.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

class InspectorRail extends ConsumerWidget {
  const InspectorRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(workflowProvider);
    final ctrl = ref.read(workflowProvider.notifier);

    return Container(
      width: AnchorSpacing.propertiesWidth,
      decoration: BoxDecoration(
        color: AnchorColors.white,
        border: Border(left: BorderSide(color: AnchorColors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AnchorColors.slate50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AnchorColors.border),
              ),
              child: Row(
                children: [
                  _Tab(
                    label: 'Node',
                    selected: s.sideTab == SidePanelTab.properties,
                    onTap: () => ctrl.setSideTab(SidePanelTab.properties),
                  ),
                  _Tab(
                    label: 'Records',
                    selected: s.sideTab == SidePanelTab.records,
                    onTap: () => ctrl.setSideTab(SidePanelTab.records),
                  ),
                  _Tab(
                    label: 'Vars',
                    selected: s.sideTab == SidePanelTab.variables,
                    onTap: () => ctrl.setSideTab(SidePanelTab.variables),
                  ),
                  _Tab(
                    label: 'Run',
                    selected: s.sideTab == SidePanelTab.preview,
                    onTap: () => ctrl.setSideTab(SidePanelTab.preview),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: switch (s.sideTab) {
              SidePanelTab.properties => s.selectedNode != null
                  ? const PropertiesPanel(embedded: true)
                  : const _EmptyNode(),
              SidePanelTab.records => const RecordsPanel(),
              SidePanelTab.variables => const VariablesPanel(embedded: true),
              SidePanelTab.preview => const PreviewPanel(embedded: true),
            },
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: selected ? AnchorColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          elevation: selected ? 1 : 0,
          shadowColor: Colors.black26,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AnchorColors.foreground
                      : AnchorColors.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNode extends StatelessWidget {
  const _EmptyNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 28,
            color: AnchorColors.slate300,
          ),
          const SizedBox(height: 12),
          Text(
            'Select a node to configure it',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AnchorColors.foreground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Or open Records to pick a ticket, purchase order, device or spare part to preview with.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AnchorColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
