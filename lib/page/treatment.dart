import 'package:flutter/material.dart';
import 'olah_napas.dart';
import 'peregangan.dart';
import 'homepage.dart';
import 'calendar.dart';
import 'chatbot.dart';

class TreatmentsScreen extends StatelessWidget {
  const TreatmentsScreen({super.key});

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required BuildContext context,
    required Widget screen,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // Prevent navigating to the same screen if already selected
        if (!(isSelected && screen.runtimeType == TreatmentsScreen)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: isSelected ? Colors.blue : Colors.pink, // Changed from Colors.grey to Colors.pink
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.pink, // Changed from Colors.grey to Colors.pink
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Treatments',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
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
            const Spacer(), // Provides space from the top
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.self_improvement,
                        size: 40, color: Colors.pink[300]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BreathTrainingPage(),
                        ),
                      );
                    },
                    child: const Text('Olah Nafas',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.accessibility,
                        size: 40, color: Colors.purple[300]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PereganganScreen(),
                        ),
                      );
                    },
                    child: const Text('Peregangan',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const Spacer(), // Provides space below
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    context: context,
                    screen: const HomeScreen(),
                    isSelected: false,
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
                    isSelected: true, // Treatment icon is selected
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
            ),
          ],
        ),
      ),
    );
  }
}
