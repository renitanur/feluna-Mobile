import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/page/treatment.dart';

void main() {
  testWidgets('Navigation bar items render correctly', (WidgetTester tester) async {
    // Render the TreatmentsScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: TreatmentsScreen(),
      ),
    );

    // Verifikasi bahwa elemen navigasi Home ada
    expect(find.text('Home'), findsOneWidget);
    expect(find.widgetWithIcon(Column, Icons.home), findsOneWidget);

    // Verifikasi bahwa elemen navigasi Treatment ada dan dipilih
    expect(find.text('Treatment'), findsOneWidget);
    final selectedIcon = tester.widget<Icon>(
      find.descendant(
        of: find.widgetWithIcon(Column, Icons.healing),
        matching: find.byType(Icon),
      ),
    );
    expect(selectedIcon.color, Colors.blue); // Karena dipilih
  });
}
