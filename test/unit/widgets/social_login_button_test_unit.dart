import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:feluna/widgets/social_login_button.dart';  // Sesuaikan dengan path aplikasi Anda

// Mock classes
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

// ignore: must_be_immutable
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

class MockHttpClient extends Mock implements http.Client {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SocialLoginButton Test', () {
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
    late MockHttpClient mockHttpClient;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() async {
      // Initial setup for mock objects
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
      mockHttpClient = MockHttpClient();
      mockSharedPreferences = MockSharedPreferences();

      // Simulate GoogleSignIn returning a mock account
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
      
      // Simulate authentication object
      when(mockGoogleSignInAccount.authentication).thenAnswer(
        (_) async => mockGoogleSignInAuthentication,
      );
      when(mockGoogleSignInAuthentication.idToken).thenReturn('mock_token');
      when(mockGoogleSignInAuthentication.accessToken).thenReturn('mock_access_token');

      // Simulate a successful server response
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/google_login.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'message': 'Login berhasil!', 'user_id': 1}),
          200,
        ),
      );

      // Simulate SharedPreferences
      SharedPreferences.setMockInitialValues({});
      when(mockSharedPreferences.setBool('isLoggedIn', true)).thenAnswer((_) async => true);
      when(mockSharedPreferences.setString('email', 'mock_email@example.com')).thenAnswer((_) async => true);
      when(mockSharedPreferences.setString('username', 'mock_username')).thenAnswer((_) async => true);
      when(mockSharedPreferences.setInt('user_id', 1)).thenAnswer((_) async => true);
    });

    testWidgets('should sign in with Google and navigate to home', (tester) async {
      // Set up widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialLoginButton(),
          ),
          routes: {
            '/home': (_) => Scaffold(),
          },
        ),
      );

      // Find the Google login button
      final googleLoginButton = find.byType(SocialLoginButton);

      // Simulate tapping the login button
      await tester.tap(googleLoginButton);
      await tester.pump();

      // Verify that Google Sign-In was called
      verify(mockGoogleSignIn.signIn()).called(1);

      // Verify that the server request was made
      verify(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/google_login.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);

      // Verify that SharedPreferences were set
      verify(mockSharedPreferences.setBool('isLoggedIn', true)).called(1);
      verify(mockSharedPreferences.setString('email', 'mock_email@example.com')).called(1);
      verify(mockSharedPreferences.setString('username', 'mock_username')).called(1);
      verify(mockSharedPreferences.setInt('user_id', 1)).called(1);

      // Verify that navigation occurred
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle Google sign-in failure', (tester) async {
      // Simulate Google Sign-In failure by returning null
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      // Set up widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialLoginButton(),
          ),
        ),
      );

      // Find the Google login button
      final googleLoginButton = find.byType(SocialLoginButton);

      // Simulate tapping the login button
      await tester.tap(googleLoginButton);
      await tester.pump();

      // Verify that Google Sign-In was called but no further action was taken
      verify(mockGoogleSignIn.signIn()).called(1);

      // Verify that no HTTP request was made
      verifyNever(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/google_login.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ));
    });
  });
}
