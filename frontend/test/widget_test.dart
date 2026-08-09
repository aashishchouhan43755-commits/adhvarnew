import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app.dart';

void main() {
  testWidgets('Adhvar app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AdhvarApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
