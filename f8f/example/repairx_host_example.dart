/// Example RepairX-style host wiring (reference only).
///
/// Copy patterns into your RepairX app — this file is not imported by the package.
library;

import 'package:autoflow/autoflow.dart';
import 'package:flutter/material.dart';

class RepairxFlowHostExample extends StatefulWidget {
  const RepairxFlowHostExample({super.key, required this.flowId});

  final String flowId;

  @override
  State<RepairxFlowHostExample> createState() => _RepairxFlowHostExampleState();
}

class _RepairxFlowHostExampleState extends State<RepairxFlowHostExample> {
  final _controller = AutoFlowController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AutoFlowBuilder(
        controller: _controller,
        catalog: repairxDemoCatalog,
        variables: buildDefaultVariableSchema(),
        sampleRecord: buildDefaultSampleRecord(),
        chrome: EmbedChrome.minimal,
        callbacks: AutoFlowCallbacks(
          onWorkflowChanged: (doc) {
            // ignore: avoid_print
            print('autosave ${doc.id} v${doc.version}');
          },
          onTriggerConfigured: (binding) {
            // ignore: avoid_print
            print('index trigger ${binding.type}');
          },
          onRequestCodePreview: (node, ctx) async {
            return {'result': 'ok', 'echo': node.config['code']};
          },
        ),
      ),
    );
  }
}
