import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import TapGestureRecognizer
import 'dart:convert'; // Untuk encoding dan decoding JSON
import 'package:http/http.dart' as http; // Untuk HTTP request
import 'forgot_password.dart'; // Import halaman ForgotPasswordScreen
import 'register.dart'; // Import halaman RegisterScreen
import '../widgets/social_login_button.dart'; // Import SocialLoginButton
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk menangani input pengguna
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variabel untuk mengecek apakah password disembunyikan atau tidak
  bool isPasswordObscured = true;
  bool isLoading = false;
  String errorMessage = ''; // Variabel untuk menyimpan pesan error

  // Fungsi untuk login
  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      errorMessage = ''; // Reset error message saat mencoba login
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://api.feluna.my.id/login.php'), // Ganti dengan URL server PHP API Anda
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': usernameController.text, // Mengirimkan username/email
          'password': passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseData['message'] == 'Login berhasil!') {
        final username = responseData['username'] ?? 'Guest';
        final email = responseData['email'] ?? 'guest@example.com';
        final userId = responseData['user_id'];

        // Simpan username dan email ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('email', email);
        await prefs.setInt('user_id', userId);
        await prefs.setBool('isLoggedIn', true);

        // Login berhasil, navigasi ke halaman berikutnya
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Menyimpan pesan error untuk ditampilkan
        setState(() {
          errorMessage = responseData['error'] ?? "Login gagal";
        });
      }
    } catch (error) {
      print("Error: $error");
      setState(() {
        errorMessage = "Terjadi kesalahan, coba lagi nanti.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk toggle visibility password
  void togglePasswordVisibility() {
    setState(() {
      isPasswordObscured = !isPasswordObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures UI adapts when keyboard is shown
      body: Container(
        width: double.infinity, // Ensures the container takes the full width
        height: double.infinity, // Ensures the container takes the full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFAACBE3),
              Color(0xFFFFF3F8),
              Color(0xFFFFD0E8),
            ],
            stops: [0.0061, 0.3997, 0.994],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 56, 22, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Halo! Selamat datang kembali',
                    style: TextStyle(
                      color: Color(0xFFBB578E),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText:
                              'Username atau Email', // Memberi petunjuk bahwa pengguna bisa pakai username atau email
                          labelStyle: const TextStyle(
                            color: Color(0xFF8391A1),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F8F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8ECF4)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8ECF4)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText:
                            isPasswordObscured, // Menggunakan variabel isPasswordObscured
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Color(0xFF8391A1),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F8F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8ECF4)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8ECF4)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Ganti icon berdasarkan apakah password disembunyikan atau tidak
                              isPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF8391A1),
                            ),
                            onPressed:
                                togglePasswordVisibility, // Fungsi untuk toggle visibility password
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Menampilkan pesan error di bawah form
                // Menampilkan pesan error di bawah form
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Align(
                      alignment: Alignment
                          .centerLeft, // Mengubah alignment pesan error ke kiri
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: Color(0xFF6A707C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFD91BE),
                    minimumSize: const Size(331, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 35),
                const Text(
                  'Atau Login Dengan',
                  style: TextStyle(
                    color: Color(0xFF6A707C),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                const SocialLoginButton(), // Ganti gambar menjadi tombol login sosial
                const SizedBox(height: 155),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Urbanist',
                    ),
                    children: [
                      const TextSpan(
                        text: 'Belum Punya Akun? ',
                        style: TextStyle(
                          color: Color(0xFF6A707C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Register Sekarang',
                        style: const TextStyle(
                          color: Color(0xFFFF3F8F),
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
