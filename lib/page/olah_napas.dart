import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

class BreathTrainingPage extends StatelessWidget {
  const BreathTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tata Cara"),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Set AppBar to transparent
        elevation: 0, // Remove AppBar shadow
        iconTheme: const IconThemeData(color: Colors.black), // Optional: Change icon color
        titleTextStyle: const TextStyle(
          color: Colors.black, // Change title color to black
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Petunjuk Penggunaan Olah Napas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      "Ikuti langkah-langkah berikut untuk memulai latihan olah napas:"),
                  const SizedBox(height: 10),
                  const OrderedList([
                    "Cari tempat yang nyaman dan tenang.",
                    "Duduk dengan posisi punggung tegak namun rileks.",
                    "Masukan jumlah berapa kali anda ingin melakukan olah nafas di kolom \"Jumlah\".",
                    "Pilih musik pendamping jika anda ingin pengalaman yang lebih baik.",
                    "Atur volume musik dan suara denting sesuai keinginan anda"
                    "Klik \"Play\" untuk memulai olah napas"
                    "Ikuti pergerakan titik atau suara denting untuk melakukan pergerakan \"Tarik\", \"Hembuskan\" dan \"Tahan\" .",
                  ]),
                  const SizedBox(height: 10),
                  const Text(
                    "Catatan: Jika merasa pusing atau tidak nyaman, segera berhenti dan beristirahat.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 248, 117, 117),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LineAnimationPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        "Mulai",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SoundOption {
  final String name;
  final String assetPath;

  SoundOption(this.name, this.assetPath);
}

enum SoundType {
  Meditation,
  BirdNature,
  ForestVeil,
  NoiseCalming,
  RainMemory,
  RiverSerenade,
  SunsetBeach,
}

Map<SoundType, SoundOption> soundOptions = {
  SoundType.Meditation: SoundOption("Meditation", "sound/meditation.mp3"),
  SoundType.BirdNature: SoundOption("Bird Nature", "sound/bird_nature.mp3"),
  SoundType.ForestVeil: SoundOption("Forest Veil", "sound/forest_veil.mp3"),
  SoundType.NoiseCalming:
      SoundOption("Noise Calming", "sound/noise_calming.mp3"),
  SoundType.RainMemory: SoundOption("Rain Memory", "sound/rain_memory.mp3"),
  SoundType.RiverSerenade:
      SoundOption("River Serenade", "sound/river_serenade.mp3"),
  SoundType.SunsetBeach: SoundOption("Sunset Beach", "sound/sunset_beach.mp3"),
};

class OrderedList extends StatelessWidget {
  final List<String> items;

  const OrderedList(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.isNotEmpty
          ? items
              .asMap()
              .entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text("${entry.key + 1}. ${entry.value}"),
                ),
              )
              .toList()
          : [const Text("No items to display")],
    );
  }
}

class LineAnimationPage extends StatefulWidget {
  const LineAnimationPage({super.key});

  @override
  _LineAnimationPageState createState() => _LineAnimationPageState();
}

class _LineAnimationPageState extends State<LineAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController _loopController = TextEditingController();
  int _targetLoops = 0; // Target looping from user input
  int _currentLoops = 0; // Current loop counter
  bool _isRunning = false; // Animation status (running or not)
  String _currentText = "Tarik"; // Animation text (Tarik, Hembuskan, Tahan)

  final AudioPlayer _audioPlayer = AudioPlayer(); // Main audio player
  final AudioPlayer _backgroundPlayer = AudioPlayer(); // Background audio player
  double _volume = 0.5; // Default volume for main sound
  double _soundVolume = 0.5; // Default volume for background sound

  SoundType? _selectedSound;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14), // Total duration per loop (3+6+5)
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addListener(() {
      setState(() {
        _updateTextBasedOnProgress(_animation.value);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentLoops++;
        });
        if (_currentLoops < _targetLoops) {
          _controller.forward(from: 0.0);
        } else {
          _controller.stop();
          setState(() {
            _isRunning = false;
          });
          _backgroundPlayer.stop();
          _showCompletionDialog(); // Show completion dialog with sound
        }
      }
    });
  }

  void _updateTextBasedOnProgress(double progress) {
    if (progress < 3 / 14) {
      if (_currentText != "Tarik") {
        _currentText = "Tarik";
        _playSound(); // Play sound for Tarik
      }
    } else if (progress < 9 / 14) {
      if (_currentText != "Hembuskan") {
        _currentText = "Hembuskan";
        _playSound(); // Play sound for Hembuskan
      }
    } else {
      if (_currentText != "Tahan") {
        _currentText = "Tahan";
        _playSound(); // Play sound for Tahan
      }
    }
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop(); // Stop previous sound if any
      await _audioPlayer.setVolume(_volume); // Set volume from slider
      await _audioPlayer
          .play(AssetSource('sound/aba-aba.mp3')); // Path to asset sound
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _showCompletionDialog() async {
    // Play completion notification sound
    await _audioPlayer.play(AssetSource('sound/aba-aba.mp3')); // Path to asset sound

    // Show dialog after sound is played
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Selesai"),
          content: const Text("Anda telah menyelesaikan pelatihan!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _startOrResumeAnimation() {
    final inputLoops = int.tryParse(_loopController.text);
    if (inputLoops != null && inputLoops > 0) {
      setState(() {
        if (!_isRunning) {
          _targetLoops = inputLoops;
          _isRunning = true;
        }
      });
      _controller.forward();
      _playBackgroundSound();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Masukkan jumlah pelatihan yang anda inginkan!")),
      );
    }
  }

  void _playBackgroundSound() async {
    if (_selectedSound != null) {
      try {
        final sound = soundOptions[_selectedSound]!;
        await _backgroundPlayer.stop();
        await _backgroundPlayer.setVolume(_soundVolume);
        await _backgroundPlayer.setReleaseMode(ReleaseMode.loop); // Set looping
        await _backgroundPlayer
            .play(AssetSource(sound.assetPath)); // Play background sound
      } catch (e) {
        print("Error playing background sound: $e");
      }
    }
  }

  void _stopAnimation() {
    _controller.stop();
    _backgroundPlayer.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetAnimation() {
    _controller.reset();
    _backgroundPlayer.stop();
    setState(() {
      _currentLoops = 0;
      _isRunning = false;
      _currentText = "Tarik";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _loopController.dispose();
    _audioPlayer.dispose(); // Dispose audio player
    _backgroundPlayer.dispose(); // Dispose background audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive text and padding
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingHorizontal = screenWidth * 0.04; // 4% of screen width

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents resizing when keyboard appears
      appBar: AppBar(
        title: const Text("Pelatihan"),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Optional: Customize AppBar color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to previous page
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: paddingHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    // Top Controls: Sound and Volume
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sound Dropdown and Volume Slider
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("Sound:", style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 5), // Reduced spacing
                                  Expanded(
                                    child: DropdownButton<SoundType>(
                                      isExpanded: true, // Make dropdown take available width
                                      value: _selectedSound,
                                      hint: const Text("Pilih"),
                                      items: soundOptions.entries
                                          .map((entry) => DropdownMenuItem<SoundType>(
                                                value: entry.key,
                                                child: Text(entry.value.name),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedSound = value;
                                          if (_selectedSound != null) {
                                            _playBackgroundSound();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8), // Reduced spacing
                              Row(
                                children: [
                                  const Text(
                                    "Volume:",
                                    style: TextStyle(fontSize: 14, color: Colors.pink),
                                  ),
                                  const SizedBox(width: 5), // Reduced spacing
                                  Expanded(
                                    child: Slider(
                                      value: _soundVolume,
                                      min: 0.0,
                                      max: 1.0,
                                      divisions: 10,
                                      activeColor: Colors.pink,
                                      inactiveColor: Colors.grey,
                                      onChanged: (value) {
                                        setState(() {
                                          _soundVolume = value;
                                          if (_selectedSound != null) {
                                            _backgroundPlayer.setVolume(_soundVolume);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8), // Reduced spacing between columns
                        // Jumlah Input and Volume Slider
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Jumlah:",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 5), // Reduced spacing
                                  Expanded(
                                    child: TextField(
                                      controller: _loopController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 10,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8), // Reduced spacing
                              Row(
                                children: [
                                  const Text(
                                    "Volume:",
                                    style: TextStyle(fontSize: 14, color: Colors.pink),
                                  ),
                                  const SizedBox(width: 5), // Reduced spacing
                                  Expanded(
                                    child: Slider(
                                      value: _volume,
                                      min: 0.0,
                                      max: 1.0,
                                      divisions: 10,
                                      activeColor: Colors.pink,
                                      inactiveColor: Colors.grey,
                                      onChanged: (value) {
                                        setState(() {
                                          _volume = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04), // 4% of screen height
                    // Central Animation and Text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[400],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(screenWidth * 0.7, screenWidth * 0.7), // Slightly reduced size
                                painter: LinePainter(progress: _animation.value),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Selesai: $_currentLoops / $_targetLoops",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_controller.isAnimating) {
                                    _stopAnimation();
                                  } else {
                                    _startOrResumeAnimation();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _controller.isAnimating
                                      ? Colors.red
                                      : Colors.pink[300],
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 20.0),
                                ),
                                child: Text(
                                  _controller.isAnimating
                                      ? "Stop"
                                      : (_currentLoops > 0 &&
                                              _currentLoops < _targetLoops
                                          ? "Resume"
                                          : "Play"),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _resetAnimation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 95, 172, 226),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 20.0),
                                ),
                                child: const Text(
                                  "Reset",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double progress;

  LinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.pink.shade200
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final paintCircle = Paint()
      ..color = Colors.pink.shade400
      ..style = PaintingStyle.fill;

    final start1 = Offset(size.width * 0.1, size.height * 0.9);
    final peak1 = Offset(size.width * 0.3, size.height * 0.1);
    final end1 = Offset(size.width * 0.6, size.height * 0.9);
    final end2 = Offset(size.width * 0.9, size.height * 0.9);

    Offset currentPosition;

    if (progress < 3 / 14) {
      final t = progress / (3 / 14);
      currentPosition = Offset(
        lerpDouble(start1.dx, peak1.dx, t)!,
        lerpDouble(start1.dy, peak1.dy, t)!,
      );
    } else if (progress < 9 / 14) {
      final t = (progress - (3 / 14)) / (6 / 14);
      currentPosition = Offset(
        lerpDouble(peak1.dx, end1.dx, t)!,
        lerpDouble(peak1.dy, end1.dy, t)!,
      );
    } else {
      final t = (progress - (9 / 14)) / (5 / 14);
      currentPosition = Offset(
        lerpDouble(end1.dx, end2.dx, t)!,
        end1.dy,
      );
    }

    canvas.drawLine(start1, peak1, paintLine);
    canvas.drawLine(peak1, end1, paintLine);
    canvas.drawLine(end1, end2, paintLine);

    canvas.drawCircle(currentPosition, 10, paintCircle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
