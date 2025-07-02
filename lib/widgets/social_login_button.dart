import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: <String>['email'], // Meminta izin untuk email pengguna
      );

      // Menghapus sesi yang ada (Jika ada)
      await googleSignIn.signOut();

      // Lakukan login menggunakan Google
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return; // User canceled the login
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? token = googleAuth.idToken;

      // Kirim token Google ke server untuk verifikasi atau registrasi
      final response = await http.post(
        Uri.parse(
            'https://api.feluna.my.id/google_login.php'), // Ganti dengan URL server kamu
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': googleUser.email, 'token': token}),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);

          // Mengecek apakah login berhasil
          if (responseData['message'] == 'Login berhasil!') {
            // Dapatkan user_id dari response dan simpan di SharedPreferences
            final int userId = responseData[
                'user_id']; // Assuming 'user_id' is an integer returned by the server
            final String username = googleUser.displayName ?? 'Guest';
            final String email = googleUser.email;

            // Simpan email, username, dan user_id ke SharedPreferences
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setString('email', email);
            await prefs.setString('username', username);
            await prefs.setInt(
                'user_id', userId); // Simpan user_id sebagai integer
            await prefs.setBool('isLoggedIn', true);

            // Navigasi ke halaman beranda
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            print(responseData['error']);
          }
        } catch (e) {
          print("Error parsing response: $e");
        }
      } else {
        print("Server Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Error during Google Sign-In: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _signInWithGoogle(context),
      child: Image.asset(
        'assets/logo google.png', // Gambar tombol Google
        width: 105,
        height: 56,
        semanticLabel: 'Login with Google',
      ),
    );
  }
}
