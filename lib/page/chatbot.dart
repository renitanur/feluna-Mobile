// lib/chatbot_screen.dart
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'calendar.dart';
import 'treatment.dart';
import '../services/chatbot_service.dart'; // Import layanan API

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = []; // List untuk menyimpan pesan pengguna
  List<String> botMessages = []; // List untuk menyimpan pesan bot
  final ChatbotService _chatbotService = ChatbotService(); // Inisialisasi layanan API
  bool _isLoading = false; // Indikator pemuatan

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text.trim();
      setState(() {
        messages.add(userMessage); // Menambahkan pesan pengguna ke list
        _isLoading = true; // Mulai pemuatan
      });
      _controller.clear(); // Mengosongkan input setelah mengirim pesan

      try {
        final botResponse = await _chatbotService.sendMessage(userMessage);
        setState(() {
          botMessages.add(botResponse); // Menambahkan balasan bot ke list
        });
      } catch (e) {
        setState(() {
          botMessages.add('Terjadi kesalahan: $e'); // Menambahkan pesan kesalahan
        });
      } finally {
        setState(() {
          _isLoading = false; // Selesai pemuatan
        });
      }
    }
  }

  Widget _buildMessage(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.pink[100] : Colors.pink[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggabungkan pesan pengguna dan bot
    List<Widget> chatMessages = [];
    int maxLength = messages.length > botMessages.length ? messages.length : botMessages.length;
    for (int i = 0; i < maxLength; i++) {
      if (i < messages.length) {
        chatMessages.add(_buildMessage(messages[i], true));
      }
      if (i < botMessages.length) {
        chatMessages.add(_buildMessage(botMessages[i], false));
      }
    }

    return Scaffold(
      // Hapus backgroundColor dari Scaffold
      body: Container(
        // Tambahkan dekorasi untuk latar belakang
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_chatbot.png'),
            fit: BoxFit.cover, // Sesuaikan sesuai kebutuhan
          ),
        ),
        child: Row(
          children: [
            // Sidebar dengan logo dan ikon navigasi
            Container(
              width: 80, // Tetapkan lebar tetap untuk sidebar
              color: Colors.white.withOpacity(0), // Opsional: warna latar belakang
              child: Column(
                children: [
                  const SizedBox(height: 40), // Spacer antara tombol kembali dan logo
                  // Logo
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/logo.png', // Logo di atas sidebar
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(height: 5), // Spacer antara logo dan ikon navigasi
                  // Ikon Navigasi
                  Column(
                    children: [
                      // Ikon Home
                      IconButton(
                        icon: const Icon(Icons.home, color: Color(0xFFD16193)),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        },
                      ),
                      const Text(
                        'Home',
                        style: TextStyle(
                          color: Color(0xFFD16193),
                          fontSize: 10, // Ukuran font kecil untuk keterangan
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Ikon Tracking
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Color(0xFFD16193)),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MenstrualTrackerPage()),
                          );
                        },
                      ),
                      const Text(
                        'Tracking',
                        style: TextStyle(
                          color: Color(0xFFD16193),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Ikon Treatment
                      IconButton(
                        icon: const Icon(Icons.person, color: Color(0xFFD16193)),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const TreatmentsScreen()),
                          );
                        },
                      ),
                      const Text(
                        'Treatment',
                        style: TextStyle(
                          color: Color(0xFFD16193),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Ikon Clear Chat
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFD16193)), // Ikon delete chat
                        onPressed: () {
                          setState(() {
                            messages.clear();
                            botMessages.clear(); // Menghapus semua pesan pengguna dan bot
                          });
                        },
                      ),
                      const Text(
                        'Clear Chat',
                        style: TextStyle(
                          color: Color(0xFFD16193),
                          fontSize: 10, // Ukuran font kecil untuk keterangan
                        ),
                      ),
                    ],
                  ),
                  const Spacer(), // Dorong konten yang tersisa ke bawah
                ],
              ),
            ),
            // Area Chat Utama
            Expanded(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent, // Transparan agar menyatu dengan wallpaper
                    elevation: 0,
                    automaticallyImplyLeading: false, // Remove default back button
                    actions: [],
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: chatMessages,
                    ),
                  ),
                  if (_isLoading) const LinearProgressIndicator(),
                  // Field Input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type Here',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onSubmitted: (value) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Send
                        CircleAvatar(
                          backgroundColor: Colors.pink[200],
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage, // Panggil fungsi _sendMessage
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});
}
