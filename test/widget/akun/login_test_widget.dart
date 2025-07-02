import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/akun/login.dart';

void main() {
  testWidgets('LoginScreen widget test', (WidgetTester tester) async {
    
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    
    expect(find.text('Halo! Selamat datang kembali'), findsOneWidget);
    
    expect(find.byType(TextFormField), findsNWidgets(2));
    
    expect(find.text('Login'), findsOneWidget);
    
    await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    
    await tester.tap(find.text('Login'));
    
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
