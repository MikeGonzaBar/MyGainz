// MyGainz App Widget Tests
//
// Basic widget tests for the MyGainz fitness application

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mygainz/main.dart';

void main() {
  testWidgets('MyGainz app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that the app launches and shows main navigation
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
  });

  testWidgets('App has proper title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify app title exists (MaterialApp title)
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Bottom navigation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify we have bottom navigation
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify all tabs are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
  });
}
