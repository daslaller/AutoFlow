import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/api/autoflow_builder.dart';
import 'package:autoflow/api/autoflow_callbacks.dart';
import 'package:autoflow/api/autoflow_controller.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/domain/variables.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_theme.dart';
import 'package:autoflow/theme/anchor_theme_presets.dart';

class AutoFlowApp extends StatefulWidget {
  const AutoFlowApp({
    super.key,
    this.embedMinimal = false,
    this.controller,
    this.themePreset,
    this.showThemePicker = true,
  });

  final bool embedMinimal;
  final AutoFlowController? controller;

  /// Demo `?theme=` id (`anchor`, `midnight`, `workshop`, `harbor`, `studio`).
  final String? themePreset;
  final bool showThemePicker;

  @override
  State<AutoFlowApp> createState() => _AutoFlowAppState();
}

class _AutoFlowAppState extends State<AutoFlowApp> {
  late String _presetId;

  @override
  void initState() {
    super.initState();
    _presetId = widget.themePreset ??
        Uri.base.queryParameters['theme'] ??
        AnchorThemePresets.anchorId;
    AnchorThemePresets.apply(_presetId);
  }

  void _setPreset(String id) {
    setState(() {
      _presetId = id;
      AnchorThemePresets.apply(id);
    });
  }

  bool get _pickerVisible {
    if (widget.embedMinimal || !widget.showThemePicker) return false;
    final q = Uri.base.queryParameters['picker'];
    if (q == '0' || q == 'false') return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoFlow',
      debugShowCheckedModeBanner: false,
      theme: buildAnchorTheme(),
      home: Stack(
        children: [
          _DemoHost(
            embedMinimal: widget.embedMinimal,
            controller: widget.controller,
          ),
          if (_pickerVisible)
            Positioned(
              left: 252,
              bottom: 40,
              child: _ThemePicker(
                selectedId: _presetId,
                onSelected: _setPreset,
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AnchorColors.card.withValues(alpha: 0.94),
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AnchorColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 8),
              child: Text(
                'Look',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AnchorColors.mutedForeground,
                ),
              ),
            ),
            for (final p in AnchorThemePresets.all)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: p.blurb,
                  child: InkWell(
                    onTap: () => onSelected(p.id),
                    borderRadius: BorderRadius.circular(7),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: p.id == selectedId
                            ? AnchorColors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: p.id == selectedId
                              ? AnchorColors.primary.withValues(alpha: 0.45)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: p.id == selectedId
                              ? AnchorColors.primary
                              : AnchorColors.chromeFg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DemoHost extends StatefulWidget {
  const _DemoHost({required this.embedMinimal, this.controller});

  final bool embedMinimal;
  final AutoFlowController? controller;

  @override
  State<_DemoHost> createState() => _DemoHostState();
}

class _DemoHostState extends State<_DemoHost> {
  late final AutoFlowController _controller =
      widget.controller ?? AutoFlowController();

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _controller.container,
      child: AutoFlowBuilder(
        controller: _controller,
        initialWorkflow: createDemoWorkflow(),
        catalog: buildDefaultCatalog(),
        variables: buildDefaultVariableSchema(),
        sampleRecord: buildDefaultSampleRecord(),
        chrome: widget.embedMinimal ? EmbedChrome.minimal : EmbedChrome.full,
        wrapWithTheme: false,
        callbacks: AutoFlowCallbacks(
          onWorkflowChanged: (_) {},
          onRequestCodePreview: (node, ctx) async {
            // Demo host: echo JS/Dart snippets as passthrough for preview.
            return {
              'result': {
                'language': node.config['lang'],
                'note': 'Host evaluated (demo)',
                'sourcePreview': (node.config['code'] ?? '').truncate(80),
              },
            };
          },
        ),
      ),
    );
  }
}

extension on String {
  String truncate(int max) =>
      length <= max ? this : '${substring(0, max)}…';
}
