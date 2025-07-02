import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_date.dart';
import 'homepage.dart';
import 'treatment.dart';
import 'chatbot.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menstrual Tracker',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MenstrualTrackerPage(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/calendar': (context) => const MenstrualTrackerPage(),
        '/treatment': (context) => const TreatmentsScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
    );
  }
}

class MenstrualTrackerPage extends StatefulWidget {
  const MenstrualTrackerPage({super.key});

  @override
  _MenstrualTrackerPageState createState() => _MenstrualTrackerPageState();
}

class _MenstrualTrackerPageState extends State<MenstrualTrackerPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _menstruationDates = [];
  final List<List<DateTime>> _menstruationPeriods = [];
  final List<DateTime> _periodStartDates =
      []; // Stores the start dates of each period
  final List<DateTime> _predictedPeriodDates = [];
  final List<DateTime> _predictedOvulationDates = [];
  int _averageCycleLength = 28; // Default cycle length
  double _averageDuration = 5.0; // Default menstruation duration

  static const int _cycleLengthDefault = 28;
  static const double _menstruationDurationDefault = 5.0;
  static const int _ovulationStart =
      14; // Days before next menstruation when ovulation occurs

  bool _hasLongDuration =
      false; // Indicates if any period duration > 16 days
  bool _hasLongCycle =
      false; // Indicates if any cycle length > 50 days
  bool _isMenstruationTomorrow =
      false; // Indicates if menstruation is predicted for tomorrow

  bool _alertShown = false; // Flag to ensure alert is shown only once

  // **Variables for Dismissible Notifications**
  bool _isMenstruationTomorrowDismissed = false;
  bool _hasLongCycleDismissed = false;
  bool _hasLongDurationDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadMenstruationDates();
  }

  // Load menstruation dates from SharedPreferences
  Future<void> _loadMenstruationDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? menstruationDatesString =
        prefs.getStringList('menstruationDates');
    if (menstruationDatesString != null && menstruationDatesString.isNotEmpty) {
      setState(() {
        _menstruationDates =
            menstruationDatesString.map((d) => DateTime.parse(d)).toList();
        _menstruationDates.sort();
        _groupMenstruationDates();
        _calculateAverageCycleAndDuration();
        _checkAbnormalPeriods();

        // **Reset Dismissed Flags When Data Changes**
        _isMenstruationTomorrowDismissed = false;
        _hasLongCycleDismissed = false;
        _hasLongDurationDismissed = false;

        // **Reset Alert Flag When Data Changes**
        _alertShown = false;
      });
    } else {
      // If no menstruation dates are recorded, reset flags and check conditions
      setState(() {
        _isMenstruationTomorrowDismissed = false;
        _hasLongCycleDismissed = false;
        _hasLongDurationDismissed = false;

        // **Reset Alert Flag**
        _alertShown = false;
      });
      _checkAbnormalPeriods();
    }
  }

  // Group menstruation dates into periods
  void _groupMenstruationDates() {
    _menstruationPeriods.clear();
    _periodStartDates.clear();
    if (_menstruationDates.isEmpty) return;

    List<DateTime> currentPeriod = [_menstruationDates[0]];
    _periodStartDates.add(_menstruationDates[0]);

    for (int i = 1; i < _menstruationDates.length; i++) {
      if (_menstruationDates[i]
              .difference(_menstruationDates[i - 1])
              .inDays ==
          1) {
        currentPeriod.add(_menstruationDates[i]);
      } else {
        _menstruationPeriods.add(currentPeriod);
        currentPeriod = [_menstruationDates[i]];
        _periodStartDates.add(_menstruationDates[i]);
      }
    }
    _menstruationPeriods.add(currentPeriod);
  }

  // Calculate average cycle length and duration
  void _calculateAverageCycleAndDuration() {
    // Calculate average menstruation duration
    if (_menstruationPeriods.isNotEmpty) {
      double totalDuration = 0;
      for (var period in _menstruationPeriods) {
        totalDuration += period.length;
      }
      _averageDuration = totalDuration / _menstruationPeriods.length;
    }

    // Calculate average cycle length based on start dates
    if (_periodStartDates.length >= 2) {
      List<int> cycleLengths = [];
      for (int i = 1; i < _periodStartDates.length; i++) {
        cycleLengths.add(_periodStartDates[i]
            .difference(_periodStartDates[i - 1])
            .inDays);
      }
      _averageCycleLength =
          (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round();
    } else {
      // If only one period exists, use default values
      _averageCycleLength = _cycleLengthDefault;
      _averageDuration = _menstruationPeriods.isNotEmpty
          ? _averageDuration
          : _menstruationDurationDefault;
    }

    // Update predictions based on average cycle and duration
    if (_periodStartDates.isNotEmpty) {
      _calculatePredictedDates(_periodStartDates.last);
    }

    // Check for abnormal periods
    _checkAbnormalPeriods();
  }

  // Save menstruation dates to SharedPreferences

  // Calculate predicted menstruation and ovulation dates
  void _calculatePredictedDates(DateTime lastPeriodStartDate) {
    setState(() {
      _predictedPeriodDates.clear();
      _predictedOvulationDates.clear();

      // Define how many future cycles to predict
      int numberOfCyclesToPredict = 6; // For example, 6 future cycles

      DateTime nextPredictedPeriod = lastPeriodStartDate;

      for (int i = 0; i < numberOfCyclesToPredict; i++) {
        // Predict next menstruation
        nextPredictedPeriod =
            nextPredictedPeriod.add(Duration(days: _averageCycleLength));
        for (int j = 0; j < _averageDuration.round(); j++) {
          _predictedPeriodDates
              .add(nextPredictedPeriod.add(Duration(days: j)));
        }

        // Predict ovulation based on _ovulationStart
        DateTime predictedOvulationDate =
            nextPredictedPeriod.subtract(const Duration(days: _ovulationStart));
        _predictedOvulationDates.add(predictedOvulationDate);
      }
    });
  }

  // Check for abnormal periods
  void _checkAbnormalPeriods() {
    bool hasLongDuration = false;
    bool hasLongCycle = false;
    bool isMenstruationTomorrow = false;

    // **Consider Only the Latest Cycle for Abnormality**
    if (_menstruationPeriods.isNotEmpty) {
      // Get the latest period
      List<DateTime> latestPeriod = _menstruationPeriods.last;
      int latestDuration = latestPeriod.length;

      if (latestDuration > 16) {
        hasLongDuration = true;
      }

      // Calculate cycle length based on the latest two period start dates
      if (_periodStartDates.length >= 2) {
        int latestCycleLength = _periodStartDates.last
            .difference(_periodStartDates[_periodStartDates.length - 2])
            .inDays;
        if (latestCycleLength > 50) {
          hasLongCycle = true;
        }
      } else {
        // If only one period exists, use default or set cycle length as abnormal if desired
        // Here, we'll consider it normal since there's no previous data
        hasLongCycle = false;
      }
    }

    // Check if menstruation is predicted for tomorrow
    if (_predictedPeriodDates.isNotEmpty) {
      DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
      for (DateTime predictedDate in _predictedPeriodDates) {
        if (isSameDay(predictedDate, tomorrow)) {
          isMenstruationTomorrow = true;
          break;
        }
      }
    }

    setState(() {
      _hasLongDuration = hasLongDuration;
      _hasLongCycle = hasLongCycle;
      _isMenstruationTomorrow = isMenstruationTomorrow;
    });

    // **Show AlertDialog if abnormal conditions are met and not already shown**
    if ((_hasLongDuration || _hasLongCycle) && !_alertShown) {
      setState(() {
        _alertShown = true; // Prevent multiple alerts
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog();
      });
    }

    // **Reset Alert Flag if Conditions are Normal**
    if (!(_hasLongDuration || _hasLongCycle)) {
      if (_alertShown) {
        setState(() {
          _alertShown = false;
        });
      }
    }
  }

  // Function to show AlertDialog warning
  void _showAlertDialog() {
    String message =
        'Menstruasi anda tidak normal, segera konsultasikan dengan dokter Obygn';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Peringatan'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Integrate with background
      appBar: AppBar(
        title: const Text('Kalender'),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
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
        child: SingleChildScrollView( // Make content scrollable
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 80.0, // Add padding to prevent content from being hidden by the bottom nav
            ),
            child: Column(
              children: [
                const SizedBox(height: 100), // Spacer for transparent AppBar

                // **Peringatan Menstruasi Besok (H-1)**
                if (_isMenstruationTomorrow && !_isMenstruationTomorrowDismissed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 253, 118, 163)
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Besok adalah perkiraan menstruasi anda',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // **Close Button**
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMenstruationTomorrowDismissed = true;
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // **Peringatan Siklus Menstruasi Lebih dari 50 Hari**
                if (_hasLongCycle && !_hasLongCycleDismissed)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Siklus menstruasi Anda lebih dari 50 hari!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // **Close Button**
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _hasLongCycleDismissed = true;
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // **Peringatan Durasi Menstruasi Lebih dari 16 Hari**
                if (_hasLongDuration && !_hasLongDurationDismissed)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Durasi menstruasi Anda lebih dari 16 hari!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // **Close Button**
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _hasLongDurationDismissed = true;
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // **Table Calendar**
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    // Highlight actual menstruation dates with pink
                    defaultBuilder: (context, day, focusedDay) {
                      if (_menstruationDates
                          .any((selectedDay) => isSameDay(selectedDay, day))) {
                        return _buildDayContainer(
                          day,
                          const Color.fromARGB(
                              255, 255, 126, 169), // Pink color for actual dates
                          icon: null, // No icon for actual menstruation
                        );
                      }

                      // Highlight predicted menstruation dates with lighter pink
                      if (_predictedPeriodDates
                          .any((predictedDay) => isSameDay(predictedDay, day))) {
                        return _buildDayContainer(
                          day,
                          Colors.pink[100]!, // Lighter pink for predictions
                          icon: const Icon(
                            Icons.fiber_manual_record,
                            color:
                                Colors.pink, // Pink bullet icon for predictions
                            size: 12,
                          ),
                        );
                      }

                      // Highlight predicted ovulation dates with blue
                      if (_predictedOvulationDates
                          .any((ovulationDay) => isSameDay(ovulationDay, day))) {
                        return _buildDayContainer(
                          day,
                          Colors.blue[100]!,
                          icon: const Icon(
                            Icons.fiber_manual_record,
                            color: Colors.blueAccent,
                            size: 12,
                          ),
                        );
                      }

                      return null;
                    },
                    // Handle selected day appearance
                    selectedBuilder: (context, day, focusedDay) {
                      // If the selected day is a menstruation day, keep pink color
                      if (_menstruationDates
                          .any((selectedDay) => isSameDay(selectedDay, day))) {
                        return _buildDayContainer(
                          day,
                          const Color.fromARGB(
                              255, 201, 59, 107), // Lighter pink when selected
                          icon: null,
                        );
                      }

                      // Otherwise, use default selected day style
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30), // Spacer between calendar and text

                // **Display Last Menstruation Date and Averages**
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _menstruationDates.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16), // Added internal padding
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent
                                .withOpacity(0.1), // Transparent pink color
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.center, // Center the text
                            children: [
                              Text(
                                'Tanggal Menstruasi Terakhir: ${_menstruationDates.last.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink),
                                textAlign: TextAlign.center, // Centered text
                              ),
                              const SizedBox(height: 10), // Added spacing between texts
                              Text(
                                'Rata-rata Siklus: $_averageCycleLength hari',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                                textAlign: TextAlign.center, // Centered text
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Rata-rata Durasi Menstruasi: ${_averageDuration.toStringAsFixed(1)} hari',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                                textAlign: TextAlign.center, // Centered text
                              ),
                              const SizedBox(height: 10),
                              // **Removed warning messages to prevent duplication**
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16), // Added internal padding
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent
                                .withOpacity(0.2), // Transparent pink color
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          child: const Text(
                            'Tanggal menstruasi belum diatur.',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center, // Centered text
                          ),
                        ),
                ),

                const SizedBox(height: 30), // Spacer between text and button

                // **"Edit Tanggal" Button**
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to EditDatePage and wait for result
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditDatePage()),
                    );
                    // Reload menstruation dates after returning
                    _loadMenstruationDates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 242, 113, 156), // Button color
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit Tanggal',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20), // Added spacing before the bottom
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(), // Fixed bottom nav
    );
  }

  // Build day container with color and optional icon
  Widget _buildDayContainer(DateTime day, Color color, {Widget? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle, // Circular shape
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (icon != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: icon,
            ),
        ],
      ),
    );
  }

  // Build Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withOpacity(0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Row(
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
                icon: Icons.calendar_month,
                label: 'Calendar',
                context: context,
                screen: const MenstrualTrackerPage(),
                isSelected: true,
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
    );
  }

  // Build individual navigation item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required BuildContext context,
    required Widget screen,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // Avoid pushing the same screen again
        if (!(isSelected && screen.runtimeType == MenstrualTrackerPage)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
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
