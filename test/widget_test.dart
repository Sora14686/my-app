import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('setState counter increments', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CounterProvider(),
        child: const BeginnerFlutterApp(),
      ),
    );

    expect(find.text('setState counter: 0'), findsOneWidget);
    expect(find.text('setState counter: 1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();

    expect(find.text('setState counter: 0'), findsNothing);
    expect(find.text('setState counter: 1'), findsOneWidget);
  });
}
