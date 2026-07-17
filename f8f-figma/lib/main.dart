import 'package:flutter/material.dart';
import 'package:autoflow/api/autoflow_controller.dart';
import 'package:autoflow/app.dart';
import 'package:autoflow/features/embed/embed_bridge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = AutoFlowController();
  controller.attach();
  registerEmbedBridge(controller.container);

  final embedMinimal = Uri.base.queryParameters['embed'] == '1';

  runApp(
    AutoFlowApp(
      embedMinimal: embedMinimal,
      controller: controller,
    ),
  );
}
