import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoflow/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AutoFlow shell shows brand and preview control', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1400, 900);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(const AutoFlowApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('AutoFlow'), findsOneWidget);
    expect(find.textContaining('Preview'), findsWidgets);
    expect(find.text('NODES'), findsOneWidget);
  });
}
