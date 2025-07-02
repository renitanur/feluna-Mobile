import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Untuk encoding dan decoding JSON
import 'login.dart'; // Import LoginScreen
import '../widgets/custom_text_field.dart'; // Import CustomTextField
import '../widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  Future<void> registerUser() async {
    setState(() {
      usernameError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        confirmPasswordError = "Password tidak cocok";
      });
      return;
    }

    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegExp.hasMatch(emailController.text)) {
      setState(() {
        emailError = "Format email tidak valid";
      });
      return;
    }

    final passwordRegExp = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{6,}$');
    if (!passwordRegExp.hasMatch(passwordController.text)) {
      setState(() {
        passwordError =
            "minimal 6 karakter, gunakan kombinasi huruf dan angka.";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.feluna.my.id/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseData['message'] == "Registrasi berhasil!") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        setState(() {
          usernameError = responseData['error'] ?? "Registrasi gagal";
        });
      }
    } catch (error) {
      setState(() {
        usernameError = "Terjadi kesalahan, coba lagi nanti.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 56, 22, 26),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  const Text(
                    'Halo! Daftar sekarang untuk join Feluna',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Color(0xFFBB578E),
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Username',
                    hintText: 'Enter your username',
                    controller: usernameController,
                  ),
                  if (usernameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        usernameError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                  ),
                  if (emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        emailError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    controller: passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  if (passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Confirm Password',
                    hintText: 'Confirm your password',
                    obscureText: _obscureConfirmPassword,
                    controller: confirmPasswordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  if (confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        confirmPasswordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFD91BE),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register'),
                  ),
                  const SizedBox(height: 35),
                  const Center(
                    child: Text(
                      'Atau Register dengan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A707C),
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(
                    child: SocialLoginButton(),
                  ),
                  const SizedBox(height: 54),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Urbanist',
                        ),
                        children: [
                          const TextSpan(
                            text: 'Sudah Punya Akun? ',
                            style: TextStyle(color: Color(0xFF6A707C)),
                          ),
                          TextSpan(
                            text: 'Login Sekarang',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF3F8F),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
