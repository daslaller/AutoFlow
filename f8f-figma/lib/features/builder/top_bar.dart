import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/design_system/brand_mark.dart';
import 'package:autoflow/design_system/buttons.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

class BuilderTopBar extends ConsumerWidget {
  const BuilderTopBar({super.key, this.onOpenPalette, this.minimal = false});

  final VoidCallback? onOpenPalette;
  final bool minimal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(workflowProvider);
    final ctrl = ref.read(workflowProvider.notifier);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: AnchorSpacing.topBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            color: Color(0xD9FFFFFF),
            border: Border(bottom: BorderSide(color: AnchorColors.border)),
            boxShadow: AnchorShadows.sm,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              return Row(
                children: [
                  if (onOpenPalette != null) ...[
                    IconButton(
                      tooltip: 'Nodes',
                      onPressed: onOpenPalette,
                      icon: const Icon(Icons.menu_rounded, size: 18),
                    ),
                    const SizedBox(width: 4),
                  ],
                  const BrandMark(size: 28, iconSize: 14, radius: 8),
                  const SizedBox(width: 8),
                  const Text(
                    'AutoFlow',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AnchorColors.foreground,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 20, color: AnchorColors.border),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: TextFormField(
                        initialValue: s.doc.name,
                        key: ValueKey(s.doc.name),
                        onChanged: ctrl.setName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AnchorColors.slate600,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Workflow name',
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!minimal) ...[
                    AnchorIconButton(
                      tooltip: s.canUndo ? 'Undo' : 'Nothing to undo',
                      onPressed: s.canUndo ? ctrl.undo : () {},
                      icon: Icon(
                        Icons.undo_rounded,
                        color: s.canUndo
                            ? AnchorColors.slate600
                            : AnchorColors.slate300,
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnchorIconButton(
                      tooltip: s.canRedo ? 'Redo' : 'Nothing to redo',
                      onPressed: s.canRedo ? ctrl.redo : () {},
                      icon: Icon(
                        Icons.redo_rounded,
                        color: s.canRedo
                            ? AnchorColors.slate600
                            : AnchorColors.slate300,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnchorIconButton(
                      tooltip: s.snapToGrid ? 'Snap on (G)' : 'Snap off (G)',
                      onPressed: ctrl.toggleSnapToGrid,
                      icon: Icon(
                        Icons.grid_on_rounded,
                        color: s.snapToGrid
                            ? AnchorColors.primary
                            : AnchorColors.slate400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnchorIconButton(
                      tooltip: 'Variables',
                      onPressed: () => ctrl.setSideTab(SidePanelTab.variables),
                      icon: const Icon(Icons.data_object_rounded),
                    ),
                    const SizedBox(width: 4),
                    AnchorIconButton(
                      tooltip: 'Preview inspector',
                      onPressed: () => ctrl.setSideTab(SidePanelTab.preview),
                      icon: const Icon(Icons.timeline_rounded),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (!minimal && wide) ...[
                    Text(
                      '${s.doc.nodes.length} nodes · ${s.doc.wires.length} edges',
                      style: AnchorTypography.monoSmall,
                    ),
                    const SizedBox(width: 8),
                    AnchorIconButton(
                      tooltip: 'Export JSON',
                      onPressed: () => _export(context, ctrl),
                      icon: const Icon(Icons.download_rounded),
                    ),
                    const SizedBox(width: 4),
                    AnchorIconButton(
                      tooltip: 'Import JSON',
                      onPressed: () => _import(context, ctrl),
                      icon: const Icon(Icons.upload_rounded),
                    ),
                    const SizedBox(width: 8),
                  ],
                  AnchorIconButton(
                    tooltip: 'Zoom out',
                    onPressed: ctrl.zoomOut,
                    icon: const Text('−', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: ctrl.zoomReset,
                    child: SizedBox(
                      width: 42,
                      child: Text(
                        '${(s.zoom * 100).round()}%',
                        textAlign: TextAlign.center,
                        style: AnchorTypography.monoSmall.copyWith(
                          color: AnchorColors.slate600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnchorIconButton(
                    tooltip: 'Zoom in',
                    onPressed: ctrl.zoomIn,
                    icon: const Text('+', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  AnchorButton(
                    label: 'Record',
                    variant: AnchorButtonVariant.outline,
                    size: AnchorButtonSize.sm,
                    onPressed: () => ctrl.setSideTab(SidePanelTab.preview),
                    icon: const Icon(Icons.fiber_manual_record, size: 12),
                  ),
                  const SizedBox(width: 6),
                  Semantics(
                    button: true,
                    label: s.isPreviewing
                        ? 'Preview running'
                        : 'Preview workflow',
                    child: AnchorButton(
                      label: s.isPreviewing
                          ? 'Preview…'
                          : (wide ? 'Preview' : 'Go'),
                      variant: AnchorButtonVariant.gradient,
                      loading: s.isPreviewing || s.isRunning,
                      onPressed: (s.isPreviewing || s.isRunning)
                          ? null
                          : () => ctrl.startPreview(record: true),
                      icon: (s.isPreviewing || s.isRunning)
                          ? null
                          : const Icon(Icons.play_arrow_rounded, size: 14),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, WorkflowController ctrl) async {
    final json = ctrl.exportJson();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Workflow'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(json, style: AnchorTypography.mono),
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
  }

  Future<void> _import(BuildContext context, WorkflowController ctrl) async {
    final field = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Workflow'),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: field,
            maxLines: 12,
            style: AnchorTypography.mono,
            decoration: const InputDecoration(
              hintText: 'Paste WorkflowDoc JSON…',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (ok == true && field.text.trim().isNotEmpty) {
      try {
        // Validate JSON before import
        jsonDecode(field.text);
        ctrl.importJson(field.text);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Import failed: $e')));
        }
      }
    }
  }
}
