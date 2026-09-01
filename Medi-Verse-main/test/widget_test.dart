import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediverse/app/app.dart';

void main() {
  testWidgets('MediVerse app initializes cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediVerseApp(),
      ),
    );
    expect(find.byType(MediVerseApp), findsOneWidget);

    // Advance 3 seconds past the splash navigation timer
    await tester.pump(const Duration(seconds: 3));

    // Unmount and flush pending timers
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
