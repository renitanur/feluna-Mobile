import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'akun/login.dart';
import 'page/homepage.dart';
import 'akun/welcome.dart';
import 'page/ubah_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feluna',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthCheck(), // Cek status login di awal
      routes: {
        '/welcome': (context) => const LoginRegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/ubah_profile': (context) => const UbahProfilePage(),
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); 
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? const HomeScreen() : const LoginRegisterScreen();
  }
}