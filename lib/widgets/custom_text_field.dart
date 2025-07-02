import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CustomTextField widget
class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;  // Menambahkan controller

  final TextEditingController? controller;  // Menambahkan controller

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.controller, // Menambahkan controller ke dalam konstruktor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Menambahkan controller di sini
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF7F8F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
        ),
        labelStyle: GoogleFonts.urbanist(
          color: const Color(0xFF8391A1),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
