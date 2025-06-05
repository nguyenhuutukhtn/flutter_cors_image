// This is a basic Flutter widget test for the flutter_cors_image package.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CustomNetworkImage widget test', (WidgetTester tester) async {
    // Build our CustomNetworkImage widget and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomNetworkImage(
            url: 'https://example.com/test-image.jpg',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );

    // Verify that the CustomNetworkImage widget is rendered
    expect(find.byType(CustomNetworkImage), findsOneWidget);
  });

  testWidgets('CustomNetworkImage with new widget parameters', (WidgetTester tester) async {
    // Test the new v0.2.0 widget-based error handling
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomNetworkImage(
            url: 'https://example.com/test-image.jpg',
            width: 200,
            height: 200,
            errorWidget: Row(
              children: [
                Icon(Icons.error),
                Text('Custom Error'),
              ],
            ),
            reloadWidget: Row(
              children: [
                Icon(Icons.refresh),
                Text('Custom Reload'),
              ],
            ),
            openUrlWidget: Row(
              children: [
                Icon(Icons.open_in_new),
                Text('Custom Open'),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify that the CustomNetworkImage widget is rendered
    expect(find.byType(CustomNetworkImage), findsOneWidget);
  });
}
