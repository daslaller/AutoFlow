import 'package:flutter/material.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/models/models.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/icons/lucide_path_icon.dart';
import 'package:flowstock/widgets/shared_widgets.dart';

class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key, required this.controller});

  final FlowController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.chromeTick,
        controller.graphTick,
      ]),
      builder: (context, _) {
        final open = controller.inspectorOpen;
        final sel = controller.selected;
        final selT = controller.selectedType;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          width: open ? 300 : 0,
          decoration: BoxDecoration(
            color: FsColors.white.withValues(alpha: 0.92),
            border: const Border(
              left: BorderSide(color: FsColors.slate200),
            ),
          ),
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerRight,
              minWidth: 300,
              maxWidth: 300,
              child: SizedBox(
                width: 300,
                child: sel == null || selT == null
                    ? const _EmptyInspector()
                    : _SelectedInspector(
                        key: ValueKey(sel.id),
                        controller: controller,
                        node: sel,
                        type: selT,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyInspector extends StatelessWidget {
  const _EmptyInspector();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                gradient: FsColors.softAiGradient,
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: LucidePathIcon(
                    pathData: Ic.zap,
                    size: 20,
                    color: FsColors.purple600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Select a node to configure',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FsColors.slate700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Drag nodes from the library onto the canvas, then drag between ports to wire the flow.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: FsColors.slate400,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedInspector extends StatefulWidget {
  const _SelectedInspector({
    super.key,
    required this.controller,
    required this.node,
    required this.type,
  });

  final FlowController controller;
  final FlowNode node;
  final NodeTypeDef type;

  @override
  State<_SelectedInspector> createState() => _SelectedInspectorState();
}

class _SelectedInspectorState extends State<_SelectedInspector> {
  final Map<String, TextEditingController> _ctrls = {};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant _SelectedInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.id != widget.node.id) {
      _disposeCtrls();
      _syncControllers();
    }
  }

  void _syncControllers() {
    for (final f in widget.type.fields) {
      if (f.type == FieldType.select) continue;
      _ctrls[f.key] = TextEditingController(
        text: widget.node.config[f.key] ?? '',
      );
    }
  }

  void _disposeCtrls() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _ctrls.clear();
  }

  @override
  void dispose() {
    _disposeCtrls();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final node = widget.node;
    final controller = widget.controller;
    final cat = NodeCatalog.categoryOf(type.category);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: FsColors.slate200)),
          ),
          child: Row(
            children: [
              ChipDecor(
                category: type.category,
                iconPath: type.iconPath,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: FsColors.slate900,
                      ),
                    ),
                    Text(
                      '${cat.label} · ${node.id}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: FsColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              HoverButton(
                tooltip: 'Delete node',
                onTap: () => controller.removeNode(node.id),
                style: BoxDecoration(borderRadius: BorderRadius.circular(7)),
                hoverStyle: BoxDecoration(
                  color: FsColors.red50,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: LucidePathIcon(
                      pathData: Ic.trash,
                      size: 14,
                      color: FsColors.slate400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final f in type.fields)
                _FieldEditor(
                  field: f,
                  value: node.config[f.key] ?? '',
                  textController: _ctrls[f.key],
                  onChanged: (v) => controller.updateField(f.key, v),
                ),
              if (type.ai)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: FsColors.purple50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '💡 Uses job + customer context automatically — no field mapping needed.',
                    style: TextStyle(
                      fontSize: 11,
                      color: FsColors.purple700,
                      height: 1.5,
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'NODE DEFINITION · JSON',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: FsColors.slate400,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FsColors.slate900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  controller.selectedJson,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.6,
                    color: FsColors.slate300,
                    fontFamily: 'Consolas',
                    fontFamilyFallback: ['Menlo', 'monospace'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldEditor extends StatelessWidget {
  const _FieldEditor({
    required this.field,
    required this.value,
    required this.onChanged,
    this.textController,
  });

  final FieldDef field;
  final String value;
  final ValueChanged<String> onChanged;
  final TextEditingController? textController;

  InputDecoration get _dec => InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: FsColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FsColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FsColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FsColors.blue500, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: FsColors.slate700,
            ),
          ),
          const SizedBox(height: 6),
          switch (field.type) {
            FieldType.select => SizedBox(
                height: 34,
                child: DropdownButtonFormField<String>(
                  initialValue: field.options.contains(value)
                      ? value
                      : (field.options.isNotEmpty ? field.options.first : null),
                  items: [
                    for (final o in field.options)
                      DropdownMenuItem(
                        value: o,
                        child: Text(
                          o,
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) onChanged(v);
                  },
                  decoration: _dec.copyWith(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: FsColors.slate900,
                  ),
                  iconSize: 18,
                  isExpanded: true,
                ),
              ),
            FieldType.text => SizedBox(
                height: 34,
                child: TextField(
                  controller: textController,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: FsColors.slate900,
                  ),
                  decoration: _dec,
                ),
              ),
            FieldType.textarea => TextField(
                controller: textController,
                onChanged: onChanged,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: FsColors.slate900,
                  height: 1.5,
                ),
                decoration: _dec.copyWith(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
            FieldType.code => TextField(
                controller: textController,
                onChanged: onChanged,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: FsColors.slate200,
                  height: 1.6,
                  fontFamily: 'Consolas',
                  fontFamilyFallback: ['Menlo', 'monospace'],
                ),
                decoration: _dec.copyWith(
                  fillColor: FsColors.slate900,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
          },
        ],
      ),
    );
  }
}
