import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/design_system/buttons.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

class PreviewPanel extends ConsumerWidget {
  const PreviewPanel({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(workflowProvider);
    final ctrl = ref.read(workflowProvider.notifier);
    final events = s.previewEvents;
    final rec = s.selectedRecord;

    final body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Preview',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                if (!embedded)
                  IconButton(
                    onPressed: () => ctrl.setSideTab(SidePanelTab.properties),
                    icon: const Icon(Icons.close, size: 16),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              rec == null
                  ? 'Pick a record, then run Preview against it.'
                  : 'Running against ${rec.title}',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AnchorColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: AnchorButton(
                    label: 'Records',
                    variant: AnchorButtonVariant.outline,
                    size: AnchorButtonSize.sm,
                    onPressed: () => ctrl.setSideTab(SidePanelTab.records),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnchorButton(
                    label: s.isPreviewing ? 'Running…' : 'Preview',
                    variant: AnchorButtonVariant.gradient,
                    size: AnchorButtonSize.sm,
                    loading: s.isPreviewing,
                    onPressed: s.isPreviewing
                        ? null
                        : () => ctrl.startPreview(record: true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text(
                      'No preview yet',
                      style: TextStyle(color: AnchorColors.slate400),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: events.length,
                    itemBuilder: (context, i) {
                      final e = events[i];
                      return _EventTile(event: e);
                    },
                  ),
          ),
          if (s.lastRecording != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: AnchorButton(
                label: 'Export recording JSON',
                variant: AnchorButtonVariant.ghost,
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Preview Recording'),
                      content: SizedBox(
                        width: 480,
                        child: SingleChildScrollView(
                          child: SelectableText(
                            const JsonEncoder.withIndent('  ')
                                .convert(s.lastRecording!.toJson()),
                            style: AnchorTypography.mono,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
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
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final PreviewEvent event;

  @override
  Widget build(BuildContext context) {
    final c = event.status.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AnchorColors.slate50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.nodeId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                event.status.name,
                style: TextStyle(fontSize: 10, color: c),
              ),
              if (event.durationMs != null) ...[
                const SizedBox(width: 6),
                Text(
                  '${event.durationMs}ms',
                  style: AnchorTypography.monoSmall,
                ),
              ],
            ],
          ),
          if (event.message != null) ...[
            const SizedBox(height: 4),
            Text(event.message!, style: const TextStyle(fontSize: 11)),
          ],
          if (event.output != null) ...[
            const SizedBox(height: 4),
            Text(
              jsonEncode(event.output),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AnchorTypography.monoSmall,
            ),
          ],
        ],
      ),
    );
  }
}
