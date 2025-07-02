import 'package:flutter/material.dart';
import 'login.dart';  // Import the LoginScreen

class PasswordSuccessScreen extends StatelessWidget {
  const PasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFAACBE3),
              Color.fromARGB(255, 243, 246, 255),
              Color(0xFFFFD0E8),
            ],
            stops: [0.0061, 0.3997, 0.994],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png', // You can update the logo path as per your assets
                    width: 100,
                    height: 100,
                    semanticLabel: 'Success Icon',
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    'Password Berhasil!',
                    style: TextStyle(
                      color: Color(0xFFBB578E),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Password anda telah berhasil diubah',
                    style: TextStyle(
                      color: Color(0xFF8391A1),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.53,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to LoginScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFD91BE),
                        padding: const EdgeInsets.symmetric(vertical: 19),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Kembali ke Login',
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
          ),
        ),
      ),
    );
  }
}
