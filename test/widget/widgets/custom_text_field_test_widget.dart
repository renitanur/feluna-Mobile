// test/widgets/custom_text_field_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/widgets/custom_text_field.dart'; // Ganti dengan path yang benar

void main() {
  testWidgets('CustomTextField widget test', (WidgetTester tester) async {
    // Membuat controller untuk inputan
    final TextEditingController controller = TextEditingController();

    // Build widget CustomTextField
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomTextField(
          label: 'Username',
          hintText: 'Enter your username',
          controller: controller,
        ),
      ),
    ));

    // Cari widget TextFormField berdasarkan label
    final Finder textFieldFinder = find.byType(TextFormField);

    // Verifikasi apakah widget TextFormField ada di widget tree
    expect(textFieldFinder, findsOneWidget);

    // Verifikasi apakah label 'Username' ditampilkan
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Enter your username'), findsOneWidget);

    // Masukkan text ke dalam TextFormField
    await tester.enterText(textFieldFinder, 'testuser');
    expect(controller.text, 'testuser');

    // Verifikasi bahwa text yang dimasukkan adalah 'testuser'
    expect(find.text('testuser'), findsOneWidget);
  });
}
