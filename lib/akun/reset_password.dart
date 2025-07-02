// password_reset.dart

import 'dart:convert'; // Import untuk encoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import untuk request HTTP
import 'package:provider/provider.dart';
import 'password_success.dart'; // Import the PasswordSuccessScreen

class PasswordResetController extends ChangeNotifier {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isPasswordVisible =
      false; // Variabel untuk mengatur visibilitas password
  bool isConfirmPasswordVisible = false; // Variabel untuk confirm password

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      notifyListeners();

      try {
        // Ambil password baru
        final newPassword = newPasswordController.text;

        // Kirim data ke API PHP
        final response = await http.post(
          Uri.parse('https://api.feluna.my.id/update_password.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'newPassword': newPassword,
          }),
        );

        final responseData = json.decode(response.body);

        if (response.statusCode == 200 && responseData['status'] == 'success') {
          // Password berhasil diubah
          isLoading = false;
          notifyListeners();

          // Navigasi ke PasswordSuccessScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const PasswordSuccessScreen()),
          );
        } else {
          // Jika ada kesalahan saat reset password
          isLoading = false;
          notifyListeners();
          _showErrorDialog(context, responseData['message']);
        }
      } catch (e) {
        // Error handling jika ada masalah dengan koneksi
        isLoading = false;
        notifyListeners();
        _showErrorDialog(context, 'Terjadi kesalahan. Coba lagi nanti.');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk toggle visibilitas password
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  // Fungsi untuk toggle visibilitas confirm password
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }
}

// PasswordResetScreen - UI part
class PasswordResetScreen extends StatelessWidget {
  final String email;

  const PasswordResetScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordResetController(),
      child: Scaffold(
        body: Consumer<PasswordResetController>(
          builder: (context, controller, child) {
            return Container(
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
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 56),
                          const SizedBox(height: 28),
                          const Text(
                            'Buat Password Baru',
                            style: TextStyle(
                              color: Color(0xFFBB578E),
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Password baru anda harus berbeda dari password yang anda gunakan sebelumnya',
                            style: TextStyle(
                              color: Color(0xFF8391A1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          const SizedBox(height: 32),
                          Form(
                            key: controller.formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: controller.newPasswordController,
                                  obscureText: !controller.isPasswordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password minimal harus 6 karakter';
                                    }
                                    // Cek apakah password mengandung kombinasi huruf dan angka
                                    if (!RegExp(
                                            r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$')
                                        .hasMatch(value)) {
                                      return 'Password harus mengandung kombinasi huruf dan angka';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password Baru',
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF8391A1),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Urbanist',
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF7F8F9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE8ECF4),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF8391A1),
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller:
                                      controller.confirmPasswordController,
                                  obscureText:
                                      !controller.isConfirmPasswordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirm Password is required';
                                    }
                                    if (value !=
                                        controller.newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF8391A1),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Urbanist',
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF7F8F9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE8ECF4),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isConfirmPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF8391A1),
                                      ),
                                      onPressed: controller
                                          .toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 38),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading
                                        ? null
                                        : () async {
                                            await controller.resetPassword(
                                                context, email);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFD91BE),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 19),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: controller.isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            'Reset Password',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Urbanist',
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
