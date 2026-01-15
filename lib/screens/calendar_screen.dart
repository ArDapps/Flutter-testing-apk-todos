
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../widgets/skylight_drawer.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isHijriMode = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // HijriCalendar.setLocal(Localizations.localeOf(context).languageCode); // context not available yet
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HijriCalendar.setLocal(Localizations.localeOf(context).languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hijriDate = HijriCalendar.fromDate(_selectedDay ?? DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: const SkylightDrawer(), // Removed drawer
      appBar: AppBar(
        title: Text(
          l10n.calendar,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        automaticallyImplyLeading: false, // Don't show back button or drawer icon
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Switch(
                value: _isHijriMode,
                onChanged: (value) {
                  setState(() {
                    _isHijriMode = value;
                  });
                },
                activeColor: const Color(0xFF1B5E20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: const Color(0xFF1B5E20)),
                const SizedBox(width: 10),
                Text(
                  _isHijriMode
                      ? hijriDate.toFormat("DDDD, dd MMMM yyyy")
                      : "${_selectedDay?.day} / ${_selectedDay?.month} / ${_selectedDay?.year}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
          if (!_isHijriMode)
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF1B5E20),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final hDate = HijriCalendar.fromDate(date);
                  return Positioned(
                    bottom: 1,
                    child: Text(
                      hDate.hDay.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hijriDate.toFormat("MMMM yyyy"),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      hijriDate.toFormat("dd"),
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      hijriDate.toFormat("DDDD"),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
