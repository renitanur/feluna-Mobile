import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../akun/login.dart'; // Pastikan path sesuai

class UbahProfilePage extends StatefulWidget {
  const UbahProfilePage({super.key});

  @override
  _UbahProfilePageState createState() => _UbahProfilePageState();
}

class _UbahProfilePageState extends State<UbahProfilePage> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newUsernameController = TextEditingController();
  String email = ""; // Variable to store the user's email
  bool _obscureOldPassword = true; // To hide/show old password
  bool _obscureNewPassword = true; // To hide/show new password

  @override
  void initState() {
    super.initState();
    _loadEmail(); // Load email from SharedPreferences
  }

  // Function to load email from SharedPreferences
  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email =
          prefs.getString('email') ?? ''; // Get email from SharedPreferences
    });
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<void> updateProfile(
    String email,
    String oldPassword,
    String newPassword,
    String newUsername,
  ) async {
    final response = await http.post(
      Uri.parse('https://api.feluna.my.id/update_profile.php'),
      body: {
        'email': email,
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_username': newUsername,
      },
    );
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        // Jika responsnya adalah string sukses, tangani sebagai string
        if (response.body.contains("Profile updated successfully")) {
          print('Profile updated successfully');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'username', newUsername); // Simpan perubahan username
          return;
        }

        // Jika respons bukan "Profile updated successfully", coba mendekode JSON
        final data = json.decode(response.body);
        print(
            "Decoded data: $data"); // Debugging: Print data yang sudah didekode

        if (data['error'] == false) {
          print('Profile updated successfully');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'username', newUsername); // Simpan perubahan username
        } else {
          throw Exception(data['message'] ?? 'Failed to update profile');
        }
      } catch (e) {
        // Tangani jika ada kesalahan saat mendekode response
        print("Error decoding response: $e");
        print("Response body: ${response.body}");
        throw Exception('Failed to parse response: $e');
      }
    } else {
      // Status code selain 200 menandakan error
      throw Exception(
          'Failed to update profile. Status code: ${response.statusCode}');
    }
  }

  // Fungsi untuk menghapus akun
  Future<bool> deleteAccount(String email, String confirmEmail) async {
    final response = await http.post(
      Uri.parse('https://api.feluna.my.id/delete_account.php'),
      body: {
        'email': email,
        'confirm_email': confirmEmail,
      },
    );
    print("Delete Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print("Decoded delete data: $data"); // Debugging

        if (data['error'] == false) {
          print('Account deleted successfully');
          // Hapus data SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          return true; // Penghapusan berhasil
        } else {
          throw Exception(data['message'] ?? 'Failed to delete account');
        }
      } catch (e) {
        // Tangani jika ada kesalahan saat mendekode response
        print("Error decoding delete response: $e");
        print("Response body: ${response.body}");
        throw Exception('Failed to parse response: $e');
      }
    } else {
      // Status code selain 200 menandakan error
      throw Exception(
          'Failed to delete account. Status code: ${response.statusCode}');
    }
  }

  // Fungsi untuk menampilkan dialog hapus akun
  Future<void> _showDeleteAccountDialog() async {
    final TextEditingController deleteEmailController = TextEditingController();
    final TextEditingController confirmDeleteEmailController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Agar tidak bisa ditutup dengan klik di luar
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Hapus Akun'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: deleteEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Masukkan email untuk menghapus akun',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email harus diisi';
                      }
                      // Tambahkan validasi email jika perlu
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: confirmDeleteEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Email',
                      hintText: 'Masukkan kembali email untuk konfirmasi',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi email harus diisi';
                      }
                      if (value != deleteEmailController.text) {
                        return 'Email konfirmasi tidak cocok';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  : TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Tutup dialog
                      },
                      child: const Text('Batal'),
                    ),
              isLoading
                  ? Container()
                  : TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            bool success = await deleteAccount(email,
                                confirmDeleteEmailController.text.trim());
                            if (success) {
                              Navigator.of(context).pop(); // Tutup dialog

                              // Navigasi ke LoginScreen dan hapus semua halaman sebelumnya
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Ubah Profile',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: email.isEmpty // Wait until email is loaded
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromARGB(255, 243, 246, 255),
                    Color.fromARGB(255, 54, 68, 118),
                  ],
                  stops: [0.3997, 0.994],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: kToolbarHeight + 30),
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/background_profile.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: -70,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage('assets/profile.png'),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileInputField(
                            controller: newUsernameController,
                            label: 'Username Baru',
                            hintText: 'Masukkan username baru',
                          ),
                          ProfileInputFieldWithIcon(
                            controller: oldPasswordController,
                            label: 'Password Lama',
                            hintText: 'Masukkan password lama',
                            obscureText: _obscureOldPassword,
                            onToggle: () {
                              setState(() {
                                _obscureOldPassword = !_obscureOldPassword;
                              });
                            },
                          ),
                          ProfileInputFieldWithIcon(
                            controller: newPasswordController,
                            label: 'Password Baru',
                            hintText: 'Masukkan password baru',
                            obscureText: _obscureNewPassword,
                            onToggle: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_isValidPassword(newPasswordController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password minimal 6 karakter')),
                          );
                          return;
                        }

                        try {
                          // Panggil API untuk memperbarui profil di database
                          await updateProfile(
                            email, // Kirimkan email dari SharedPreferences
                            oldPasswordController.text,
                            newPasswordController.text,
                            newUsernameController.text,
                          );

                          // Simpan perubahan ke SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              'username', newUsernameController.text);

                          // Navigate to ProfilePage dengan nilai yang diperbarui
                          Navigator.pop(context, {
                            'username': newUsernameController.text,
                            'email':
                                email, // Pastikan email tetap sama jika tidak diubah
                          });
                        } catch (e) {
                          // Tampilkan error jika gagal memperbarui profil
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 54, 68, 118),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child: const Text('Simpan',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // Panggil dialog hapus akun
                        await _showDeleteAccountDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Warna merah untuk tombol hapus
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child: const Text('Hapus Akun',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
    );
  }
}

class ProfileInputFieldWithIcon extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggle;

  const ProfileInputFieldWithIcon({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.pink),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;

  const ProfileInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.pink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
