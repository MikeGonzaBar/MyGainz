// MyGainz App Widget Tests
//
// Basic widget tests for the MyGainz fitness application

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mygainz/main.dart';

void main() {
  testWidgets('MyGainz app creates successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app widget tree is created
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App shows loading or auth state initially',
      (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Wait a short time for initial render
    await tester.pump();

    // Should show loading text, or at minimum have a Scaffold
    final hasLoading = find.text('Loading...').evaluate().isNotEmpty;
    final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;

    expect(hasLoading || hasScaffold, true);
  });

  testWidgets('App has proper theme configuration',
      (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Find the MaterialApp
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    // Verify app title
    expect(materialApp.title, 'MyGainz');

    // Verify debug banner is disabled
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}
