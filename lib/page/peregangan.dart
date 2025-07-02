import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:feluna/widgets/camera_view.dart';

class PereganganScreen extends StatefulWidget {
  const PereganganScreen({super.key});

  @override
  _PereganganScreenState createState() => _PereganganScreenState();
}

class _PereganganScreenState extends State<PereganganScreen> {
  final List<Map<String, String>> gifData = [
    {"path": 'assets/pose/reclining_twist.gif', "name": "Pose Reclining Twist"},
    {"path": 'assets/pose/cat_cow.gif', "name": "Pose Cat Cow"},
    {"path": 'assets/pose/child.gif', "name": "Pose Child"},
    {"path": 'assets/pose/cobra.gif', "name": "Pose Cobra"},
    {"path": 'assets/pose/corpse.gif', "name": "Pose Corpse"},
  ];

  late final List<Map<String, String>> loopingGifData;
  late PageController _pageController;
  late AudioPlayer _audioPlayer;

  int currentIndex = 0;
  bool isPlaying = false;
  String? currentSound;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Tambahkan elemen untuk looping
    loopingGifData = [
      gifData.last,
      ...gifData,
      gifData.first,
    ];

    _pageController = PageController(initialPage: 1);
  }

  void onPageChanged(int index) {
    setState(() {
      if (index == 0) {
        Future.delayed(Duration.zero, () {
          _pageController.jumpToPage(loopingGifData.length - 2);
          currentIndex = gifData.length - 1;
        });
      } else if (index == loopingGifData.length - 1) {
        Future.delayed(Duration.zero, () {
          _pageController.jumpToPage(1);
          currentIndex = 0;
        });
      } else {
        currentIndex = index - 1;
      }
    });
  }

  void playSound(String sound) async {
    if (currentSound != sound || !isPlaying) {
      await _audioPlayer.stop();
      String soundPath = _getSoundPath(sound);
      await _audioPlayer.play(AssetSource(soundPath));
      setState(() {
        isPlaying = true;
        currentSound = sound;
      });
    }
  }

  void stopSound() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  String _getSoundPath(String sound) {
    switch (sound) {
      case "River Serenade":
        return 'sound/river_serenade.mp3';
      case "Meditation":
        return 'sound/meditation.mp3';
      case "Bird Nature":
        return 'sound/bird_nature.mp3';
      case "Forest Veil":
        return 'sound/forest_veil.mp3';
      case "Noise Calming":
        return 'sound/noise_calming.mp3';
      case "Rain Memory":
        return 'sound/rain_memory.mp3';
      case "Sunset Beach":
        return 'sound/sunset_beach.mp3';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Method to navigate to CameraView
  void navigateToCameraView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect the current orientation
    Orientation orientation = MediaQuery.of(context).orientation;

    // Define different gradients for portrait and landscape
    Gradient backgroundGradient = orientation == Orientation.portrait
        ? const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFAACBE3),
              Color(0xFFFFF3F8),
              Color(0xFFFFD0E8),
            ],
            stops: [0.0061, 0.3997, 0.994],
          )
        : const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFFD0E8),
              Color(0xFFFFF3F8),
              Color(0xFFAACBE3),
            ],
            stops: [0.0, 0.5, 1.0],
          );

    // Get screen size for responsive text and padding
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic font sizes and paddings
    double titleFontSize = screenWidth * 0.05; // 5% of screen width
    double buttonFontSize = screenWidth * 0.04; // 4% of screen width
    double paddingHorizontal = screenWidth * 0.04; // 4% of screen width
    double paddingTop = screenHeight * 0.1; // 10% of screen height

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Peregangan',
          style: TextStyle(
            fontSize: titleFontSize,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: paddingTop, left: paddingHorizontal, right: paddingHorizontal),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: onPageChanged,
                      itemCount: loopingGifData.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
                            }
                            return Center(
                              child: Transform.scale(
                                scale: value,
                                child: child,
                              ),
                            );
                          },
                          child: Image.asset(
                            loopingGifData[index]['path']!,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04), // 2% of screen height
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    gifData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      width: currentIndex == index ? 8.0 : 6.0,
                      height: currentIndex == index ? 8.0 : 6.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == index
                            ? const Color.fromARGB(255, 253, 108, 156)
                            : const Color.fromARGB(255, 200, 200, 200),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04), // 4% of screen height
                Text(
                  gifData[currentIndex]['name']!,
                  style: TextStyle(
                    fontSize: titleFontSize * 1.2, // Slightly larger than title
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: const Color.fromARGB(255, 253, 108, 156),
                    fontFamily: 'Urbanist',
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // 4% of screen height
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: DropdownButtonFormField<String>(
                    value: currentSound,
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Choose Sound',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    onChanged: (String? newSound) {
                      setState(() {
                        currentSound = newSound;
                      });
                    },
                    items: [
                      "River Serenade",
                      "Meditation",
                      "Bird Nature",
                      "Forest Veil",
                      "Noise Calming",
                      "Rain Memory",
                      "Sunset Beach",
                    ]
                        .map<DropdownMenuItem<String>>((String sound) {
                      return DropdownMenuItem<String>(
                        value: sound,
                        child: Text(
                          sound,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04), // 4% of screen height
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (currentSound != null && !isPlaying) {
                          playSound(currentSound!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                            horizontal: screenWidth * 0.05),
                      ),
                      child: Text(
                        "Play",
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05), // 5% of screen width
                    ElevatedButton(
                      onPressed: () {
                        if (isPlaying) {
                          stopSound();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                            horizontal: screenWidth * 0.05),
                      ),
                      child: Text(
                        "Stop",
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05), // 5% of screen width
                    ElevatedButton(
                      onPressed: navigateToCameraView,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                            horizontal: screenWidth * 0.05),
                      ),
                      child: Text(
                        "Aktifkan Kamera",
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02), // 2% of screen height
                // Removed the camera preview section
              ],
            ),
          ),
        ),
      ),
    );
  }
}
