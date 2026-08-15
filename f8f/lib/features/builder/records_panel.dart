import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/domain/records.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_typography.dart';

class RecordsPanel extends ConsumerStatefulWidget {
  const RecordsPanel({super.key});

  @override
  ConsumerState<RecordsPanel> createState() => _RecordsPanelState();
}

class _RecordsPanelState extends ConsumerState<RecordsPanel> {
  String _query = '';

  static const _order = [
    'ticket',
    'purchase_order',
    'device',
    'spare_part',
    'message',
  ];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(workflowProvider);
    final ctrl = ref.read(workflowProvider.notifier);
    final q = _query.toLowerCase();
    final records = s.previewRecords.where((r) {
      if (q.isEmpty) return true;
      return r.title.toLowerCase().contains(q) ||
          r.subtitle.toLowerCase().contains(q) ||
          r.collection.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q);
    }).toList();

    final grouped = <String, List<DataRecord>>{};
    for (final r in records) {
      grouped.putIfAbsent(r.collection, () => []).add(r);
    }

    final selected = s.selectedRecord;
    final vars = s.effectiveVariables;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Records',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick a shop row to preview against. Its fields become variables you can reference.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AnchorColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search tickets, POs, devices…',
              hintStyle: TextStyle(
                color: AnchorColors.mutedForeground,
                fontSize: 13,
              ),
              isDense: true,
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 16,
                color: AnchorColors.mutedForeground,
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: records.isEmpty
              ? Center(
                  child: Text(
                    s.previewRecords.isEmpty
                        ? 'No records from the host yet'
                        : 'No records match',
                    style: TextStyle(color: AnchorColors.mutedForeground),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  children: [
                    for (final key in _order)
                      if (grouped[key] != null) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                          child: Text(
                            grouped[key]!.first.collectionLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.7,
                              color: AnchorColors.mutedForeground,
                            ),
                          ),
                        ),
                        for (final r in grouped[key]!)
                          _RecordTile(
                            record: r,
                            selected: r.id == s.selectedRecordId,
                            onTap: () => ctrl.selectRecord(r.id),
                          ),
                      ],
                    for (final e in grouped.entries)
                      if (!_order.contains(e.key)) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                          child: Text(
                            e.value.first.collectionLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.7,
                              color: AnchorColors.mutedForeground,
                            ),
                          ),
                        ),
                        for (final r in e.value)
                          _RecordTile(
                            record: r,
                            selected: r.id == s.selectedRecordId,
                            onTap: () => ctrl.selectRecord(r.id),
                          ),
                      ],
                  ],
                ),
        ),
        if (selected != null)
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AnchorColors.border)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Text(
                    'Variables from ${selected.title}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a path in Vars to insert it into the selected node.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AnchorColors.mutedForeground,
                    ),
                  ),
                  for (final group in vars.groups) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
                      child: Text(
                        group.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AnchorColors.slate500,
                        ),
                      ),
                    ),
                    for (final v in group.variables) _VarRow(variable: v),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.selected,
    required this.onTap,
  });

  final DataRecord record;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? AnchorColors.blue50
            : AnchorColors.slate50,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AnchorColors.blue200 : AnchorColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AnchorColors.primary
                        : AnchorColors.slate300,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AnchorColors.foreground,
                        ),
                      ),
                      if (record.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          record.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: AnchorColors.mutedForeground,
                          ),
                        ),
                      ],
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

class _VarRow extends StatelessWidget {
  const _VarRow({required this.variable});

  final VariableVar variable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variable.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AnchorColors.foreground,
                  ),
                ),
                Text(
                  '{{${variable.path}}}',
                  style: AnchorTypography.monoSmall.copyWith(
                    color: AnchorColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${variable.example ?? '—'}',
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AnchorColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
