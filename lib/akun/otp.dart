import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'reset_password.dart'; // Import PasswordResetScreen

class OtpInput extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const OtpInput(
      {super.key, required this.controllers, required this.focusNodes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 70,
          height: 60,
          child: TextFormField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7F8F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE8ECF4),
                  width: 1.2,
                ),
              ),
            ),
            style: const TextStyle(
              color: Color(0xFFFF3F8F),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.length == 1 && index < 3) {
                focusNodes[index + 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }
}

class VerifyButton extends StatelessWidget {
  final String email;
  final List<TextEditingController> controllers;

  const VerifyButton(
      {super.key, required this.email, required this.controllers});

  Future<void> _verifyOtp(BuildContext context) async {
    String otp = controllers.map((controller) => controller.text).join('');
    if (otp.length == 4) {
      // Kirim request HTTP untuk memverifikasi OTP
      var response = await http.post(
        Uri.parse('https://api.feluna.my.id/verify_otp.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var data =
            json.decode(response.body); // Coba parsing respons sebagai JSON
        if (data['status'] == 'success') {
          // Navigasi ke layar reset password jika OTP valid
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordResetScreen(
                  email: email), // Pass email ke reset password screen
            ),
          );
        } else {
          // Menampilkan dialog jika OTP tidak valid
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(data['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Tangani pengecualian jika respons tidak dalam format JSON
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid response from server'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Menampilkan dialog jika OTP tidak 4 digit
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter a valid 4-digit OTP.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _verifyOtp(context),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFD91BE),
          padding: const EdgeInsets.symmetric(vertical: 19),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Verify',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(4, (index) => TextEditingController());
    focusNodes = List.generate(4, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> sendOtpToEmail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.feluna.my.id/send_otp.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        // Mengasumsikan server mengirimkan JSON
        final responseData = jsonDecode(response.body);

        if (responseData['message'] != null) {
          // OTP berhasil dikirim, arahkan ke halaman OTP Verification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('OTP has been sent again to ${widget.email}')),
          );
        } else {
          setState(() {
            errorMessage =
                responseData['error'] ?? 'Terjadi kesalahan, coba lagi nanti.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 56, 22, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    color: Color(0xFFBB578E),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Masukkan kode verifikasi yang telah kami kirimkan ke ${widget.email}',
                  style: const TextStyle(
                    color: Color(0xFF838BA1),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                OtpInput(controllers: controllers, focusNodes: focusNodes),
                const SizedBox(height: 38),
                VerifyButton(email: widget.email, controllers: controllers),
                const Spacer(),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15),
                      children: [
                        const TextSpan(
                          text: "Didn't receive code? ",
                          style: TextStyle(color: Color(0xFF838BA1)),
                        ),
                        TextSpan(
                          text: 'Resend',
                          style: const TextStyle(color: Color(0xFFFF3F8F)),
                          recognizer: TapGestureRecognizer()
                            ..onTap =
                                sendOtpToEmail, // Calls the sendOtpToEmail method
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
    );
  }
}
