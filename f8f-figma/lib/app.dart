import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/api/autoflow_builder.dart';
import 'package:autoflow/api/autoflow_callbacks.dart';
import 'package:autoflow/api/autoflow_controller.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/domain/variables.dart';
import 'package:autoflow/theme/anchor_theme.dart';

class AutoFlowApp extends StatelessWidget {
  const AutoFlowApp({
    super.key,
    this.embedMinimal = false,
    this.controller,
  });

  final bool embedMinimal;
  final AutoFlowController? controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoFlow',
      debugShowCheckedModeBanner: false,
      theme: buildAnchorTheme(),
      home: _DemoHost(
        embedMinimal: embedMinimal,
        controller: controller,
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
                'sourcePreview': '${node.config['code'] ?? ''}'.truncate(80),
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
