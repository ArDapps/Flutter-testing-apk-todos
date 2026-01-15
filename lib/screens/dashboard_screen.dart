import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../providers/font_size_provider.dart';
import '../widgets/profile_column.dart';
import '../widgets/chores_column.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _onTaskCompleted(bool isNowCompleted) {
    if (isNowCompleted) {
      _confettiController.play();
      _audioPlayer.play(AssetSource('sounds/clapping.mp3'));
      _flutterTts.speak("Great job!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;
    final todoProvider = Provider.of<TodoProvider>(context);

    // Group todos by profile
    Map<String, List<Todo>> profileTodos = {};
    for (var profile in todoProvider.profiles) {
      profileTodos[profile.id] = todoProvider.todos
          .where((t) => t.profileId == profile.id && t.category != 'chore')
          .toList();
    }
    
    // Get chores (todos with category 'chore')
    List<Todo> chores = todoProvider.todos.where((t) => t.category == 'chore').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft background
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Top Header
              _buildHeader(scale),
              
              // Main Content
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
                  children: [
                    ...todoProvider.profiles.map((profile) {
                      return ProfileColumn(
                        profile: profile,
                        todos: profileTodos[profile.id] ?? [],
                        onAddPressed: () => _showAddTaskDialog(context, profileId: profile.id),
                        onTaskCompleted: (todo, isCompleted) {
                          // TodoItem handles the toggle internally via Provider
                          // We just check if it became completed to play the sound
                          _onTaskCompleted(isCompleted);
                        }, 
                      );
                    }),
                    
                    // Special Chores Column
                    ChoresColumn(
                      chores: chores,
                      onChoreToggled: (chore, value) {
                        todoProvider.toggleTodoStatus(chore.id);
                        _onTaskCompleted(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Confetti Overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
              createParticlePath: _drawStar,
              emissionFrequency: 0.05,
              numberOfParticles: 150,
              gravity: 0.1,
              minBlastForce: 60,
              maxBlastForce: 120,
            ),
          ),
        ],
      ),
    );
  }

  Path _drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Widget _buildHeader(double scale) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final dateStr = DateFormat('EEE, MMM d').format(now);
    final timeStr = DateFormat('h a').format(now);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32 * scale, vertical: 24 * scale),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$dateStr $timeStr',
                style: TextStyle(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8 * scale),
              Row(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.orange, size: 20 * scale),
                  SizedBox(width: 8 * scale),
                  Text(
                    '72°F',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Right side controls
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 20 * scale, color: Colors.grey.shade700),
                SizedBox(width: 8 * scale),
                Text(l10n.filter, style: TextStyle(fontSize: 14 * scale, color: Colors.grey.shade700)),
              ],
            ),
          ),
          SizedBox(width: 16 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(l10n.today, style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.w600)),
          ),
          SizedBox(width: 16 * scale),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.chevron_left, size: 24 * scale),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.chevron_right, size: 24 * scale),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, {String? profileId}) {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    String category = profileId != null ? 'general' : 'chore'; // Default to chore if no profile
    String? selectedProfileId = profileId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final todoProvider = Provider.of<TodoProvider>(context, listen: false);
          // If profileId is null and we select 'general', pick first profile default
          if (category == 'general' && selectedProfileId == null && todoProvider.profiles.isNotEmpty) {
            selectedProfileId = todoProvider.profiles.first.id;
          }

          return AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: category,
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('Personal Task')),
                    DropdownMenuItem(value: 'chore', child: Text('Shared Chore')),
                    DropdownMenuItem(value: 'grocery', child: Text('Grocery')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      category = val!;
                      if (category == 'chore' || category == 'grocery') {
                        selectedProfileId = null;
                      } else if (category == 'general' && selectedProfileId == null && todoProvider.profiles.isNotEmpty) {
                        selectedProfileId = todoProvider.profiles.first.id;
                      }
                    });
                  },
                ),
                if (category == 'general') ...[
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedProfileId,
                    hint: const Text('Assign to...'),
                    items: todoProvider.profiles.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedProfileId = val;
                      });
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    todoProvider.addTodo(
                      titleController.text,
                      category: category,
                      profileId: selectedProfileId,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }
}
