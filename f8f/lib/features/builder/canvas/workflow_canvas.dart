import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/autoflow_node.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';

/// Editor canvas backed by HeidNodes (`FlNodesWidget`).
class WorkflowCanvas extends ConsumerStatefulWidget {
  const WorkflowCanvas({super.key});

  @override
  ConsumerState<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends ConsumerState<WorkflowCanvas> {
  /// The beams keep HeidNodes' active-links ticker running, and that ticker is
  /// vended by a descendant's `TickerProvider` — which Flutter disposes before
  /// this widget, and before the host disposes the controller. `deactivate`
  /// runs on the way *down*, so it is the one moment where the ticker can
  /// still be stopped cleanly. See [HeidGraph.pauseLinkEffects].
  @override
  void deactivate() {
    ref.read(workflowProvider.notifier).graph.pauseLinkEffects();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    ref.read(workflowProvider.notifier).graph.resumeLinkEffects();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(workflowProvider.notifier);
    final controller = ctrl.graph.controller;
    final session = ctrl.graph.session;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.delete): ctrl.deleteSelected,
        const SingleActivator(LogicalKeyboardKey.backspace): ctrl.deleteSelected,
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): ctrl.undo,
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): ctrl.undo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): ctrl.redo,
        const SingleActivator(LogicalKeyboardKey.keyY, meta: true): ctrl.redo,
        const SingleActivator(LogicalKeyboardKey.keyZ, shift: true, control: true):
            ctrl.redo,
        const SingleActivator(LogicalKeyboardKey.keyZ, shift: true, meta: true):
            ctrl.redo,
        const SingleActivator(LogicalKeyboardKey.keyC, control: true):
            ctrl.copySelected,
        const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
            ctrl.copySelected,
        const SingleActivator(LogicalKeyboardKey.keyV, control: true):
            ctrl.pasteClipboard,
        const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
            ctrl.pasteClipboard,
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            ctrl.requestSave,
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
            ctrl.requestSave,
        const SingleActivator(LogicalKeyboardKey.keyG): ctrl.toggleSnapToGrid,
        const SingleActivator(LogicalKeyboardKey.escape): () => ctrl.select(null),
        const SingleActivator(LogicalKeyboardKey.arrowLeft):
            () => ctrl.nudgeSelected(-1, 0),
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            () => ctrl.nudgeSelected(1, 0),
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            () => ctrl.nudgeSelected(0, -1),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            () => ctrl.nudgeSelected(0, 1),
      },
      child: Focus(
        autofocus: true,
        child: DragTarget<NodeDef>(
          onAcceptWithDetails: (details) {
            final world = RenderBoxUtils.screenToWorld(
              controller.editorKey,
              details.offset,
              controller.viewportOffset,
              controller.viewportZoom,
            );
            ctrl.addNodeFromDef(
              details.data,
              world?.dx ?? 120,
              world?.dy ?? 120,
            );
          },
          builder: (context, candidate, rejected) {
            return FlNodesWidget(
              controller: controller,
              expandToParent: true,
              nodeBuilder: (node, heid) => AutoflowNodeWidget(
                node: node,
                controller: heid,
                session: session,
                showPortContextMenu: _portMenu,
                showNodeCreationMenu: _nodeCreationMenu,
                showNodeContextMenu: _nodeMenu,
              ),
              showPortContextMenu: _portMenu,
              showCanvasContextMenu: _canvasMenu,
              showNodeCreationMenu: _nodeCreationMenu,
              showLinkContextMenu: _linkMenu,
            );
          },
        ),
      ),
    );
  }
}

void _portMenu(
  BuildContext context,
  Offset position,
  FlNodesController controller,
  PortLocator locator,
) {
  _showItems(context, position, [
    PopupMenuItem<String>(
      child: const Text('Disconnect'),
      onTap: () => controller.breakPortLinks(locator.nodeId, locator.portId),
    ),
  ]);
}

void _nodeMenu(
  BuildContext context,
  Offset position,
  FlNodesController controller,
  FlNodeDataModel node,
) {
  _showItems(context, position, [
    PopupMenuItem<String>(
      child: const Text('Delete node'),
      onTap: () => controller.removeNodeById(node.id),
    ),
  ]);
}

void _linkMenu(
  BuildContext context,
  String linkId,
  Offset position,
  FlNodesController controller,
) {
  _showItems(context, position, [
    PopupMenuItem<String>(
      child: const Text('Delete wire'),
      onTap: () => controller.removeLinkById(linkId),
    ),
  ]);
}

void _canvasMenu(
  BuildContext context,
  Offset position,
  FlNodesController controller,
  PortLocator? locator,
) {
  _showItems(context, position, [
    PopupMenuItem<String>(
      child: const Text('Reset view'),
      onTap: () {
        controller.setViewportOffset(Offset.zero, absolute: true, animate: false);
        controller.setViewportZoom(1, absolute: true, animate: false);
      },
    ),
  ]);
}

void _nodeCreationMenu(
  BuildContext context,
  Offset lastFocalPoint,
  FlNodesController controller,
  PortLocator? locator,
  void Function() onTmpLinkCancel,
) {
  // Palette is the node-creation UI; dropping a wire on empty canvas cancels it.
  onTmpLinkCancel();
}

Future<void> _showItems(
  BuildContext context,
  Offset position,
  List<PopupMenuEntry<String>> items,
) {
  return showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    items: items,
  );
}
