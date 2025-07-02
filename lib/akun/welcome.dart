import 'package:flutter/material.dart';
import 'login.dart';  // Import LoginScreen
import 'register.dart';  // Import RegisterScreen

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({super.key});

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
              Color(0xFFFFF3F8),
              Color(0xFFFFD0E8),
            ],
            stops: [0.0061, 0.3997, 0.994],
          ),
        ),
        
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),  // Menambah jarak di atas gambar untuk memindahkan gambar lebih ke bawah
                Image.asset(
                  'assets/000.png',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke LoginScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFD91BE),
                    minimumSize: const Size(331, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () {
                    // Navigasi ke RegisterScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(331, 58),
                    side: const BorderSide(
                      color: Color(0xFF1E232C),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Color(0xFFFF3F8F),
                      fontSize: 15,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 94),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
