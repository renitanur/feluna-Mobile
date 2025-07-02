// test/widgets/social_login_button_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/widgets/social_login_button.dart'; // Ganti dengan path yang benar
import 'package:mockito/mockito.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  testWidgets('SocialLoginButton widget test', (WidgetTester tester) async {
    // Menyediakan MockGoogleSignIn
    final MockGoogleSignIn mockGoogleSignIn = MockGoogleSignIn();

    // Menyediakan widget untuk diuji
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialLoginButton(),
        ),
      ),
    );

    // Temukan tombol login Google di widget
    expect(find.byType(InkWell), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Simulasikan tap pada tombol login
    await tester.tap(find.byType(InkWell));
    await tester.pump(); // Tunggu perubahan UI setelah tap

    // Verifikasi bahwa GoogleSignIn telah dipanggil (memanggil _signInWithGoogle)
    verify(mockGoogleSignIn.signIn()).called(1);
  });
}
