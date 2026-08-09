import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maham_app/core/widgets/loading_widget.dart';

void main() {
  testWidgets('LoadingWidget renders custom message successfully',
      (WidgetTester tester) async {
    // Build LoadingWidget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingWidget(message: 'جاري تحميل البيانات...'),
        ),
      ),
    );

    // Verify the custom loading message is rendered
    expect(find.text('جاري تحميل البيانات...'), findsOneWidget);
    // Verify progress indicator is rendered
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
