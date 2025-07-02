import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import library http
import 'calendar.dart';
import 'treatment.dart';
import 'chatbot.dart';
import 'profile.dart';
import '../akun/login.dart';

class HomeScreen extends StatelessWidget {
  // Constructor
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Membuat status bar transparan
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Metode untuk mengirim umpan balik
    Future<void> sendFeedback(String feedback, BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Mengambil user_id sebagai int dan mengubahnya menjadi String
      int? userIdInt =
          prefs.getInt('user_id'); // Mendapatkan user_id sebagai int

      if (userIdInt != null) {
        // Mengubah int menjadi String
        String userId = userIdInt.toString(); // Convert to String

        // Mengirim data umpan balik ke server
        try {
          final response = await http.post(
            Uri.parse(
                'https://api.feluna.my.id/submit_feedback.php'), // Ganti dengan URL server Anda
            body: {
              'user_id': userId, // Mengirim user_id sebagai String
              'content': feedback,
            },
          );

          if (response.statusCode == 200) {
            // Memeriksa apakah server berhasil menyimpan umpan balik
            print('Umpan balik berhasil disimpan');
          } else {
            // Jika ada kesalahan dari server
            print('Gagal mengirim umpan balik');
          }
        } catch (e) {
          print('Error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Terjadi kesalahan saat mengirim umpan balik')),
          );
        }
      } else {
        // Jika user_id null
        print('User ID tidak ditemukan');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna tidak terdaftar')),
        );
      }
    }

    // Metode untuk logout
    Future<void> logout(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }

    // Metode untuk menampilkan form umpan balik
    void showFeedbackForm(BuildContext context) {
      TextEditingController feedbackController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text(
              'Umpan Balik',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kami menghargai masukan Anda. Silakan tulis umpan balik Anda di bawah ini:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: feedbackController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Tulis umpan balik Anda...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  String feedback = feedbackController.text.trim();
                  if (feedback.isNotEmpty) {
                    sendFeedback(feedback, context); // Kirim feedback ke server
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Umpan balik berhasil dikirim')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Umpan balik tidak boleh kosong')),
                    );
                  }
                },
                child: const Text('Kirim'),
              ),
            ],
          );
        },
      );
    }

    // Metode untuk keluar dari aplikasi
    void exitApp(BuildContext context) {
      // Tampilkan konfirmasi sebelum keluar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content:
                const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop(); // Keluar dari aplikasi
                },
                child: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Tampilkan konfirmasi sebelum keluar saat tombol kembali ditekan
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content:
                const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );

        if (shouldExit) {
          SystemNavigator.pop();
        }

        return Future.value(false); // Jangan biarkan pop terjadi secara default
      },
      child: Scaffold(
        extendBodyBehindAppBar: true, // Membuat body menyatu dengan AppBar
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 50,
              ),
              PopupMenuButton<String>(
                // Tombol popup menu
                icon: const Icon(
                  Icons.person,
                  color: Colors.pinkAccent,
                  size: 35,
                ),
                offset: const Offset(0, 40),
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  } else if (value == 'feedback') {
                    showFeedbackForm(context); // Panggil UI umpan balik
                  } else if (value == 'logout') {
                    logout(context);
                  } else if (value == 'exit') {
                    exitApp(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.account_circle, color: Colors.pinkAccent),
                          SizedBox(width: 10),
                          Text('Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'feedback',
                      child: Row(
                        children: [
                          Icon(Icons.feedback, color: Colors.pinkAccent),
                          SizedBox(width: 10),
                          Text('Umpan Balik'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.pinkAccent),
                          SizedBox(width: 10),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
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
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'Hai Luna',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Urbanist',
                  color: Color(0xFFBB578E),
                ),
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/000.png',
                    width: 0.8 * MediaQuery.of(context).size.width,
                    height: 550,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          icon: Icons.home,
                          label: 'Home',
                          context: context,
                          screen: const HomeScreen(),
                          isSelected: true,
                        ),
                        _buildNavItem(
                          icon: Icons.calendar_today,
                          label: 'Calendar',
                          context: context,
                          screen: const MenstrualTrackerPage(),
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: Icons.healing,
                          label: 'Treatment',
                          context: context,
                          screen: const TreatmentsScreen(),
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: Icons.chat,
                          label: 'Chatbot',
                          context: context,
                          screen: const ChatbotScreen(),
                          isSelected: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Metode untuk membangun item navigasi
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required BuildContext context,
    required Widget screen,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blueAccent : Colors.pinkAccent,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.pinkAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
