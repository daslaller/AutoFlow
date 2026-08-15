import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

class VariablesPanel extends ConsumerWidget {
  const VariablesPanel({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(workflowProvider);
    final ctrl = ref.read(workflowProvider.notifier);
    final sample = s.sampleRecord;
    final schema = s.effectiveVariables;
    final rec = s.selectedRecord;

    final body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Variables',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (!embedded)
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => ctrl.setSideTab(SidePanelTab.properties),
                        icon: const Icon(Icons.close, size: 16),
                      ),
                  ],
                ),
                if (rec != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'From ${rec.title}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AnchorColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: schema.groups.isEmpty
                ? Center(
                    child: Text(
                      'Select a record to see its fields',
                      style: TextStyle(color: AnchorColors.mutedForeground),
                    ),
                  )
                : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final group in schema.groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
                    child: Text(
                      group.label.toUpperCase(),
                      style: AnchorTypography.monoSmall.copyWith(
                        letterSpacing: 1.4,
                        color: AnchorColors.slate400,
                      ),
                    ),
                  ),
                  for (final v in group.variables)
                    _VarTile(
                      path: v.path,
                      label: v.label,
                      type: v.type,
                      example: _exampleFor(sample, v.path) ?? v.example,
                      onInsert: () {
                        final sel = s.selectedNode;
                        if (sel == null) {
                          Clipboard.setData(
                            ClipboardData(text: '{{${v.path}}}'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied {{${v.path}}}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                        // Insert into first empty-ish field or append to first field.
                        final type = s.catalog.find(sel.def.id);
                        final field = type?.fields.isEmpty ?? true
                            ? null
                            : type!.fields.first;
                        if (field == null) return;
                        final cur = sel.config[field.key] ?? '';
                        final next = cur.isEmpty
                            ? '{{${v.path}}}'
                            : '$cur{{${v.path}}}';
                        ctrl.updateSelectedConfig(field.key, next);
                        ctrl.setSideTab(SidePanelTab.properties);
                      },
                    ),
                ],
              ],
            ),
          ),
        ],
      );

    if (embedded) return body;
    return Container(
      width: AnchorSpacing.propertiesWidth,
      decoration: BoxDecoration(
        color: AnchorColors.white,
        border: Border(left: BorderSide(color: AnchorColors.border)),
      ),
      child: body,
    );
  }

  dynamic _exampleFor(Map<String, dynamic> sample, String path) {
    dynamic cur = sample;
    for (final p in path.split('.')) {
      if (cur is Map && cur.containsKey(p)) {
        cur = cur[p];
      } else {
        return null;
      }
    }
    return cur;
  }
}

class _VarTile extends StatelessWidget {
  const _VarTile({
    required this.path,
    required this.label,
    required this.type,
    required this.onInsert,
    this.example,
  });

  final String path;
  final String label;
  final String type;
  final dynamic example;
  final VoidCallback onInsert;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onInsert,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '{{$path}}',
                style: AnchorTypography.monoSmall.copyWith(
                  color: AnchorColors.primary,
                ),
              ),
              if (example != null)
                Text(
                  'e.g. $example',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AnchorColors.slate400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
