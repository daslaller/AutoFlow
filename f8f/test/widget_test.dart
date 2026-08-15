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
    expect(find.text('Nodes'), findsOneWidget);
    expect(find.text('Records'), findsWidgets);
  });

  testWidgets('picking a record lists its variables', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1400, 900);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(const AutoFlowApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Records').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('T-102'), findsWidgets);
    expect(find.textContaining('PO-1041'), findsWidgets);

    await tester.tap(find.textContaining('PO-1041').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Variables from'), findsOneWidget);
    expect(find.text('{{purchase_order.po_number}}'), findsOneWidget);
    expect(find.text('PO-1041'), findsWidgets);
  });
}
