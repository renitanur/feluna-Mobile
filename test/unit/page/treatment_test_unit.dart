import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/page/treatment.dart';

void main() {
  testWidgets('buildNavItem builds correctly', (WidgetTester tester) async {
    // Render the widget
    await tester.pumpWidget(
      MaterialApp(
        home: TreatmentsScreen().buildNavItem(
          icon: Icons.home,
          label: 'Home',
          context: tester.element(find.byType(MaterialApp)),
          screen: const TreatmentsScreen(),
          isSelected: true,
        ),
      ),
    );

    // Check if the widget is built correctly
    expect(find.text('Home'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byType(GestureDetector), findsOneWidget);
  });
}
