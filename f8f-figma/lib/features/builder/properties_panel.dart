import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/design_system/badge.dart';
import 'package:autoflow/design_system/buttons.dart';
import 'package:autoflow/design_system/input.dart';
import 'package:autoflow/design_system/label.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/node_card.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(workflowProvider);
    final node = s.selectedNode;
    if (node == null) return const SizedBox.shrink();

    final ctrl = ref.read(workflowProvider.notifier);
    final type = s.catalog.find(node.def.id);
    final fields = type?.fields ?? const <FieldDef>[];
    final c = node.def.kind.color;
    final issues =
        s.validation.where((v) => v.nodeId == node.iid).toList();

    return Container(
      width: AnchorSpacing.propertiesWidth,
      decoration: const BoxDecoration(
        color: Color(0xF7FFFFFF),
        border: Border(left: BorderSide(color: AnchorColors.border)),
        boxShadow: AnchorShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(kindIcon(node.def.kind), size: 15, color: c),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.def.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnchorBadge(
                        label: node.def.kind.label,
                        backgroundColor: c.withValues(alpha: 0.12),
                        foregroundColor: c,
                      ),
                    ],
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 16),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (issues.isNotEmpty) ...[
                  ...issues.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        i.message,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AnchorColors.destructive,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'CONFIGURATION',
                  style: AnchorTypography.monoSmall.copyWith(
                    letterSpacing: 1.8,
                    color: AnchorColors.slate400,
                  ),
                ),
                const SizedBox(height: 12),
                if (fields.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      'No configuration required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AnchorColors.slate400,
                      ),
                    ),
                  )
                else
                  ...fields.map((f) {
                    final isMulti = f.type == FieldType.textarea ||
                        f.type == FieldType.code ||
                        f.type == FieldType.json ||
                        f.type == FieldType.template;
                    if (f.type == FieldType.toggle) {
                      final on = (node.config[f.key] ?? f.defaultValue) == 'true';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            Expanded(child: AnchorLabel(f.label)),
                            Switch(
                              value: on,
                              onChanged: s.embedConfig.readOnly
                                  ? null
                                  : (v) => ctrl.updateSelectedConfig(
                                        f.key,
                                        v ? 'true' : 'false',
                                      ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (f.type == FieldType.select && f.options.isNotEmpty) {
                      final value = node.config[f.key] ??
                          f.defaultValue ??
                          f.options.first.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnchorLabel(f.label),
                            const SizedBox(height: 5),
                            DropdownButtonFormField<String>(
                              initialValue: value,
                              items: f.options
                                  .map(
                                    (o) => DropdownMenuItem(
                                      value: o.value,
                                      child: Text(o.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: s.embedConfig.readOnly
                                  ? null
                                  : (v) {
                                      if (v != null) {
                                        ctrl.updateSelectedConfig(f.key, v);
                                      }
                                    },
                              decoration: const InputDecoration(isDense: true),
                            ),
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnchorLabel(f.label),
                          const SizedBox(height: 5),
                          AnchorInput(
                            key: ValueKey('${node.iid}-${f.key}'),
                            value: node.config[f.key] ?? f.defaultValue ?? '',
                            onChanged: (v) =>
                                ctrl.updateSelectedConfig(f.key, v),
                            placeholder: f.placeholder,
                            mono: true,
                            maxLines: isMulti ? 5 : 1,
                            enabled: !s.embedConfig.readOnly,
                          ),
                          if (f.type == FieldType.variablePicker ||
                              f.type == FieldType.template)
                            TextButton(
                              onPressed: () =>
                                  ctrl.setSideTab(SidePanelTab.variables),
                              child: const Text('Browse variables'),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AnchorColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: node.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      node.status.name,
                      style: AnchorTypography.monoSmall.copyWith(
                        color: AnchorColors.slate500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnchorButton(
                  label: 'Delete Node',
                  variant: AnchorButtonVariant.destructive,
                  onPressed: s.embedConfig.readOnly
                      ? null
                      : () => ctrl.deleteNode(node.iid),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
