import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ubah_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load user profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Periksa apakah ada data yang tersimpan, jika tidak gunakan data default
      username = prefs.getString('username') ?? 'Guest';
      email = prefs.getString('email') ?? 'guest@gmail.com';
    });

    // Debugging: Cek apakah data sudah terambil dengan benar
    print("Username: $username, Email: $email");
  }

  // Update profile data in SharedPreferences
  Future<void> _updateProfileData(Map<String, String> updatedData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Pastikan data terupdate
    await prefs.setString('username', updatedData['username'] ?? username);
    await prefs.setString('email', updatedData['email'] ?? email);

    setState(() {
      username = updatedData['username'] ?? username;
      email = updatedData['email'] ?? email;
    });

    // Debugging: Cek setelah data disimpan
    print("Updated Username: $username, Updated Email: $email");
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
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Container(
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
                          image: AssetImage('assets/background_profile.jpg'),
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
              const SizedBox(height: 90),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileItem('Username', username, Icons.person),
                    _buildProfileItem('Email', email, Icons.email),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UbahProfilePage()),
                  );

                  if (updatedData != null) {
                    // Simpan data baru ke SharedPreferences
                    await _updateProfileData(updatedData);

                    // Debugging: Cek apakah data sudah terupdate
                    print("Updated Profile: ${updatedData['username']}, ${updatedData['email']}");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 54, 68, 118),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                child: const Text(
                  'Ubah Profile',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk membangun item profil
  Widget _buildProfileItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 54, 68, 118), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
