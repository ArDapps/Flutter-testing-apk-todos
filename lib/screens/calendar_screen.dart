import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../providers/font_size_provider.dart';

enum CalendarViewType { month, week, day }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Timer for updating the clock
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  CalendarViewType _currentViewType = CalendarViewType.month;
  DateTime _displayMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update time every minute
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addDummyEvents();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addDummyEvents() {
    // Check if context is valid before accessing provider
    if (!mounted) return;
    
    // Safely access the controller
    EventController? controller;
    try {
      // Use listen: false to avoid rebuilding if we are just accessing the controller
      // However, CalendarControllerProvider.of usually listens. 
      // We need to check if the widget is actually found.
      controller = CalendarControllerProvider.of(context).controller;
    } catch (e) {
      // Controller might not be found if the widget is not under CalendarControllerProvider
      debugPrint('Error accessing CalendarController: $e');
      return;
    }

    if (controller.allEvents.isEmpty) {
      final now = DateTime.now();
      
      final events = [
        CalendarEventData(
          date: now,
          title: "Demo Demo",
          startTime: DateTime(now.year, now.month, now.day, 10, 0),
          endTime: DateTime(now.year, now.month, now.day, 10, 30),
          color: const Color(0xFFF8BBD0), // Pink
        ),
        CalendarEventData(
          date: now,
          title: "Demo Demo",
          startTime: DateTime(now.year, now.month, now.day, 16, 45),
          endTime: DateTime(now.year, now.month, now.day, 17, 45),
          color: const Color(0xFFD1C4E9), // Purple
        ),
        CalendarEventData(
          date: now.add(const Duration(days: 1)),
          title: "Demo Demo",
          startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
          endTime: DateTime(now.year, now.month, now.day + 1, 10, 30),
          color: const Color(0xFFF8BBD0), // Pink
        ),
        CalendarEventData(
          date: now.add(const Duration(days: 2)),
          title: "Demo Demo",
          startTime: DateTime(now.year, now.month, now.day + 2, 18, 30),
          endTime: DateTime(now.year, now.month, now.day + 2, 19, 30),
          color: const Color(0xFFAED581), // Light Green
        ),
        CalendarEventData(
          date: now.add(const Duration(days: 2)),
          title: "Demo Demo",
          startTime: DateTime(now.year, now.month, now.day + 2, 18, 45),
          endTime: DateTime(now.year, now.month, now.day + 2, 19, 45),
          color: const Color(0xFFD1C4E9), // Purple
        ),
        CalendarEventData(
          date: now.add(const Duration(days: 3)),
          title: "Demo Demo",
          startTime: DateTime(now.year, now.month, now.day + 3, 19, 30),
          endTime: DateTime(now.year, now.month, now.day + 3, 20, 30),
          color: const Color(0xFFFFCC80), // Orange
        ),
        CalendarEventData(
          date: now.add(const Duration(days: 4)),
          title: "Demo Demo",
          startTime: DateTime(now.year, now.month, now.day + 4, 11, 0),
          endTime: DateTime(now.year, now.month, now.day + 4, 12, 0),
          color: const Color(0xFF64B5F6), // Blue
        ),
         CalendarEventData(
          date: now.add(const Duration(days: 10)),
          title: "Demo Demo",
          startTime: DateTime(now.year, now.month, now.day + 10, 10, 0),
          endTime: DateTime(now.year, now.month, now.day + 10, 11, 0),
          color: const Color(0xFF64B5F6), // Blue
        ),
        CalendarEventData(
          date: now.add(const Duration(days: 10)),
          title: "Presidents' Day",
          startTime: DateTime(now.year, now.month, now.day + 10, 0, 0),
          endTime: DateTime(now.year, now.month, now.day + 10, 23, 59),
          color: const Color(0xFFFF9800), // Dark Orange
        ),
      ];

      controller.addAll(events);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header (Time, Weather, Forecast)
            _buildTopHeader(scale, isPortrait),
            
            // 2. Title & Filters
            _buildFilterBar(scale),
            
            if (_currentViewType == CalendarViewType.month)
              _buildWeekDaysHeader(scale),
            
            // 3. Calendar View
            Expanded(
              child: _buildCalendarView(isPortrait, scale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(bool isPortrait, double scale) {
    switch (_currentViewType) {
      case CalendarViewType.week:
        return WeekView(
          controller: CalendarControllerProvider.of(context).controller,
          minDay: DateTime(1990),
          maxDay: DateTime(2050),
          initialDay: _displayMonth,
          heightPerMinute: 1.0,
          onDateTap: (date) => _showAddEventDialog(date),
          onEventTap: (events, date) => _showEventDetails(events.first),
        );
      case CalendarViewType.day:
        return DayView(
          controller: CalendarControllerProvider.of(context).controller,
          minDay: DateTime(1990),
          maxDay: DateTime(2050),
          initialDay: _displayMonth,
          heightPerMinute: 1.0,
          onDateTap: (date) => _showAddEventDialog(date),
          onEventTap: (events, date) => _showEventDetails(events.first),
        );
      default:
        return MonthView(
          controller: CalendarControllerProvider.of(context).controller,
          headerBuilder: (date) {
            return const SizedBox.shrink(); // Hide default header
          },
          cellBuilder: (date, events, isToday, isInMonth, hideDays) {
            return _buildDateCell(date, events, isToday, isInMonth, scale);
          },
          minMonth: DateTime(1990),
          maxMonth: DateTime(2050),
          initialMonth: DateTime.now(),
          cellAspectRatio: isPortrait ? 0.6 : 0.8, // Adjust for taller cells
          onPageChange: (date, pageIndex) {
            setState(() {
              _displayMonth = date;
            });
          },
          onCellTap: (events, date) {
            _showAddEventDialog(date);
          },
        );
    }
  }

  Future<void> _showAddEventDialog(DateTime date) async {
    final titleController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Event"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Event Title"),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Start Time"),
                    trailing: Text(startTime.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: startTime);
                      if (picked != null) {
                        setState(() => startTime = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text("End Time"),
                    trailing: Text(endTime.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: endTime);
                      if (picked != null) {
                        setState(() => endTime = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final event = CalendarEventData(
                        date: date,
                        title: titleController.text,
                        startTime: DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute),
                        endTime: DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute),
                        color: Colors.blue,
                      );
                      CalendarControllerProvider.of(context).controller.add(event);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showEventDetails(CalendarEventData event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Text("Time: ${event.startTime?.toString().substring(11, 16)} - ${event.endTime?.toString().substring(11, 16)}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
             onPressed: () {
               CalendarControllerProvider.of(context).controller.remove(event);
               Navigator.pop(context);
             },
             style: TextButton.styleFrom(foregroundColor: Colors.red),
             child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader(double scale) {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) => Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14 * scale,
            color: Colors.black,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTopHeader(double scale, bool isPortrait) {
    final now = _currentTime;
    final dateFormat = DateFormat('EEEE MMMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    final hijriDate = HijriCalendar.fromDate(now);
    final hijriStr = '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}';

    final timeWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          now.weekday == DateTime.tuesday ? "Tuesday" : DateFormat('EEEE').format(now), // Dynamic but mock style
          style: TextStyle(
            fontSize: 16 * scale,
            color: Colors.black,
          ),
        ),
        Text(
          dateFormat.format(now),
          style: TextStyle(
            fontSize: 20 * scale,
            color: Colors.black,
            fontFamily: 'IBMPlexSansArabic', 
          ),
        ),
        Text(
          hijriStr,
          style: TextStyle(
            fontSize: 18 * scale,
            color: const Color(0xFF1B5E20),
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSansArabic', 
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            timeFormat.format(now),
            style: TextStyle(
              fontSize: 60 * scale,
              fontWeight: FontWeight.w300,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );

    final weatherWidget = Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20 * scale,
        runSpacing: 10 * scale,
        children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Icon(Icons.cloud, color: Colors.blue, size: 40 * scale),
               SizedBox(height: 10 * scale),
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.water_drop, size: 14 * scale, color: Colors.blue),
                   Text(" 77%", style: TextStyle(fontSize: 12 * scale)),
                 ],
               ),
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.compress, size: 14 * scale, color: Colors.blue),
                   Text(" 30.11 inHg", style: TextStyle(fontSize: 12 * scale)),
                 ],
               ),
                Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.wb_sunny_outlined, size: 14 * scale, color: Colors.blue),
                   Text(" 7:10:07 AM", style: TextStyle(fontSize: 12 * scale)),
                 ],
               ),
             ],
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(
                 "75°F",
                 style: TextStyle(
                   fontSize: 48 * scale,
                   fontWeight: FontWeight.w300,
                   color: Colors.black,
                 ),
               ),
               Text("SSE 7 mi/h", style: TextStyle(fontSize: 12 * scale, color: Colors.black)),
               Text("10 mi", style: TextStyle(fontSize: 12 * scale, color: Colors.black)),
               Text("6:02:51 PM", style: TextStyle(fontSize: 12 * scale, color: Colors.black)),
             ],
           )
        ],
      ),
    );

    final forecastWidget = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildForecastItem("Tue", Icons.cloud, "66°", "66°", scale),
          SizedBox(width: 20 * scale),
          _buildForecastItem("Wed", Icons.cloud_queue, "81°", "67°", scale),
          SizedBox(width: 20 * scale),
          _buildForecastItem("Thu", Icons.wb_sunny, "82°", "67°", scale),
          SizedBox(width: 20 * scale),
          _buildForecastItem("Fri", Icons.wb_cloudy, "83°", "68°", scale),
          SizedBox(width: 20 * scale),
          _buildForecastItem("Sat", Icons.wb_sunny_outlined, "85°", "67°", scale),
        ],
      ),
    );

    if (isPortrait) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 20 * scale),
            child: Column(
              children: [
                timeWidget,
                SizedBox(height: 16 * scale),
                weatherWidget,
                SizedBox(height: 16 * scale),
                forecastWidget,
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 20 * scale),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.3, child: timeWidget),
            SizedBox(width: 16 * scale),
            SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: weatherWidget),
             SizedBox(width: 16 * scale),
            SizedBox(width: MediaQuery.of(context).size.width * 0.3, child: forecastWidget),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(String day, IconData icon, String high, String low, double scale) {
    return Column(
      children: [
        Text(day, style: TextStyle(fontSize: 12 * scale, color: Colors.black)),
        SizedBox(height: 8 * scale),
        Icon(icon, color: Colors.amber, size: 24 * scale),
        SizedBox(height: 8 * scale),
        Text(high, style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(low, style: TextStyle(fontSize: 12 * scale, color: Colors.black)),
      ],
    );
  }

  Widget _buildFilterBar(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Calendar",
            style: TextStyle(
              fontSize: 24 * scale,
              fontFamily: 'IBMPlexSansArabic',
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10 * scale),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAvatar(const Color(0xFFEF9A9A), scale),
                _buildAvatar(const Color(0xFFFFCC80), scale),
                _buildAvatar(const Color(0xFF90CAF9), scale),
                _buildAvatar(const Color(0xFFCE93D8), scale),
                _buildAvatar(const Color(0xFFA5D6A7), scale),
                _buildAvatar(const Color(0xFFF48FB1), scale),
                
                SizedBox(width: 10 * scale),
                _buildFilterPill("Family", Colors.blue, Icons.people, scale),
                _buildFilterPill("Birthdays", Colors.green, Icons.cake, scale),
                _buildFilterPill("Holidays", Colors.orange, Icons.shopping_bag, scale),
                
                SizedBox(width: 10 * scale),
                Container(
                  width: 40 * scale,
                  height: 40 * scale,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 10 * scale),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.calendar_today, size: 16 * scale),
                  label: Text("Add Event", style: TextStyle(fontSize: 14 * scale)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37474F),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 15 * scale),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * scale),
          // View selector
          PopupMenuButton<CalendarViewType>(
            initialValue: _currentViewType,
            onSelected: (CalendarViewType result) {
              setState(() {
                _currentViewType = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<CalendarViewType>>[
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.month,
                child: Text('Month View'),
              ),
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.week,
                child: Text('Week View'),
              ),
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.day,
                child: Text('Day View'),
              ),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentViewType == CalendarViewType.month ? Icons.calendar_view_month :
                    _currentViewType == CalendarViewType.week ? Icons.calendar_view_week :
                    Icons.calendar_view_day,
                    size: 16 * scale, 
                    color: Colors.black54
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    "Select View\n${_currentViewType.name[0].toUpperCase()}${_currentViewType.name.substring(1)}", 
                    style: TextStyle(fontSize: 12 * scale, height: 1.1)
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16 * scale, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Color color, double scale) {
    return Container(
      margin: EdgeInsets.only(right: 8 * scale),
      width: 40 * scale,
      height: 40 * scale,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(Icons.person, color: Colors.white, size: 20 * scale),
    );
  }

  Widget _buildFilterPill(String label, Color color, IconData icon, double scale) {
    return Container(
      margin: EdgeInsets.only(right: 8 * scale),
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16 * scale),
          SizedBox(width: 4 * scale),
          Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12 * scale)),
        ],
      ),
    );
  }

  Widget _buildDateCell(DateTime date, List<CalendarEventData> events, bool isToday, bool isInMonth, double scale) {
    if (!isInMonth) return Container(color: Colors.grey.shade50);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(4 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date + Weather
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.orange : Colors.black87,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Text(
                        "${65 + (date.day % 15)}°F / ${50 + (date.day % 10)}°F", // Mock temp
                        style: TextStyle(fontSize: 10 * scale, color: Colors.black),
                      ),
                      SizedBox(width: 4 * scale),
                      Icon(
                        date.day % 3 == 0 ? Icons.wb_sunny : (date.day % 3 == 1 ? Icons.cloud : Icons.water_drop),
                        size: 14 * scale,
                        color: date.day % 3 == 0 ? Colors.amber : Colors.blueGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 4 * scale),
          
          // Events List
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 2 * scale),
                  padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 2 * scale),
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.endTime != null && event.endTime!.difference(event.startTime!).inHours < 24)
                      Text(
                        "${DateFormat('HH:mm').format(event.startTime!)} - ${DateFormat('HH:mm').format(event.endTime!)}",
                        style: TextStyle(fontSize: 8 * scale, color: Colors.black54),
                        maxLines: 1,
                      ),
                      Text(
                        event.title,
                        style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
