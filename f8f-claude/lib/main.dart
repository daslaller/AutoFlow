import 'package:flutter/material.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/flow_builder_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlowstockApp());
}

class FlowstockApp extends StatelessWidget {
  const FlowstockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flowstock Automations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: FsColors.slate50,
        colorScheme: ColorScheme.fromSeed(
          seedColor: FsColors.blue600,
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
        fontFamilyFallback: const [
          'Roboto',
          'Helvetica Neue',
          'Arial',
          'sans-serif',
        ],
      ),
      home: const FlowBuilderPage(),
    );
  }
}
