import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('BELAGAVI PROPERTY'),
          ),
        ),
      ),
    );

    expect(find.text('BELAGAVI PROPERTY'), findsOneWidget);
  });
}
