// edit_date_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditDatePage extends StatefulWidget {
  const EditDatePage({super.key});

  @override
  _EditDatePageState createState() => _EditDatePageState();
}

class _EditDatePageState extends State<EditDatePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _selectedDays = {}; // Menggunakan Set untuk menyimpan multiple tanggal

  @override
  void initState() {
    super.initState();
    _loadMenstruationDates();
  }

  // Fungsi untuk memuat daftar tanggal menstruasi yang telah disimpan
  Future<void> _loadMenstruationDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? menstruationDates = prefs.getStringList('menstruationDates');
    if (menstruationDates != null) {
      setState(() {
        _selectedDays = menstruationDates
            .map((dateString) => DateTime.parse(dateString))
            .toSet();
        if (_selectedDays.isNotEmpty) {
          _focusedDay = _selectedDays.last;
        }
      });
    }
  }

  // Fungsi untuk menyimpan daftar tanggal menstruasi
  Future<void> _saveMenstruationDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> menstruationDates =
        _selectedDays.map((day) => day.toIso8601String()).toList();
    await prefs.setStringList('menstruationDates', menstruationDates);
    // Kembali ke halaman utama setelah menyimpan
    Navigator.pop(context);
  }

  // Fungsi untuk menambah atau menghapus tanggal dari Set<DateTime>
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tanggal'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0, // Menghilangkan shadow AppBar
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
            const SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) =>
                  _selectedDays.any((selectedDay) => isSameDay(selectedDay, day)),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarBuilders: CalendarBuilders(
                // Menggunakan selectedBuilder untuk mengubah tampilan hari yang dipilih
                selectedBuilder: (context, day, focusedDay) {
                  return _buildSelectedDayContainer(day, const Color.fromARGB(255, 252, 122, 166));
                },
                
              ),
              // Menyesuaikan gaya kalender
              calendarStyle: const CalendarStyle(
                // Menghilangkan dekorasi default selected day
                selectedDecoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.circle, // Membuat semua hari berbentuk bulat
                ),
                // Menyesuaikan teks hari yang dipilih
                selectedTextStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(color: Color.fromARGB(255, 61, 148, 255)),
              ),
            ),
            const Spacer(),
            // **Tombol Simpan**
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _selectedDays.isNotEmpty
                    ? () {
                        _saveMenstruationDates();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 107, 153), // Warna tombol
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Fungsi pembantu untuk membuat tampilan hari yang dipilih
  Widget _buildSelectedDayContainer(DateTime day, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color, // Gunakan parameter color
        shape: BoxShape.circle, // Mengubah bentuk menjadi bulat
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
