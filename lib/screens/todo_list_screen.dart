
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../providers/todo_provider.dart';
import '../providers/font_size_provider.dart';
import '../widgets/todo_item.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late ConfettiController _confettiController;
  late FlutterTts _flutterTts;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _audioPlayer = AudioPlayer();
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    
    var isLanguageAvailable = await _flutterTts.isLanguageAvailable("en-US");
    if (isLanguageAvailable) {
        await _flutterTts.setLanguage("en-US");
    }

    // Configure audio session for playback even in silent mode (iOS)
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      ],
    );
  }

  Path _drawStar(Size size) {
    // Method to draw a star
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

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onTaskCompleted(bool? isCompleted) {
    if (isCompleted == true) {
      _confettiController.play();
      _audioPlayer.play(AssetSource('sounds/clapping.mp3'));
      // SystemSound.play(SystemSoundType.click); // Removed in favor of clapping sound
      // _flutterTts.speak("Great job!"); // Optional: keep or remove based on preference
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Header & Filters (Skylight Style)
                Container(
                  padding: EdgeInsets.all(20 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.todoTitle,
                            style: TextStyle(
                              fontSize: 32 * scale,
                              fontFamily: 'IBMPlexSansArabic',
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // Add Button (Pill shape like Calendar)
                          ElevatedButton.icon(
                            onPressed: () => _showAddTodoDialog(context),
                            icon: Icon(Icons.add, size: 18 * scale),
                            label: Text(l10n.addTask, style: TextStyle(fontSize: 14 * scale)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF37474F), // Dark slate
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20 * scale),
                      // Mock Filters/Categories
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                             _buildCategoryPill("All", Colors.black87, true, scale),
                             _buildCategoryPill("Personal", const Color(0xFFEF9A9A), false, scale),
                             _buildCategoryPill("Work", const Color(0xFF90CAF9), false, scale),
                             _buildCategoryPill("Grocery", const Color(0xFFA5D6A7), false, scale),
                             _buildCategoryPill("Family", const Color(0xFFFFCC80), false, scale),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 2. Task List
                Expanded(
                  child: Consumer<TodoProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.generalTodos.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.task_alt, size: 100 * scale, color: Colors.grey.shade200),
                              const SizedBox(height: 20),
                              Text(
                                l10n.noTasks,
                                style: TextStyle(
                                  fontSize: 18 * scale,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 0),
                        itemCount: provider.generalTodos.length,
                        itemBuilder: (context, index) {
                          return TodoItem(
                            todo: provider.generalTodos[index],
                            onStatusChanged: _onTaskCompleted,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Confetti Widget
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive, // Explosive from center
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow, // Added yellow
                ],
                createParticlePath: _drawStar,
                emissionFrequency: 0.1, // Faster emission
                numberOfParticles: 100, // More particles for full screen effect
                gravity: 0.3, // Faster fall
                minBlastForce: 30, // Faster explosion
                maxBlastForce: 60, // Much faster explosion
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String label, Color color, bool isSelected, double scale) {
    return Container(
      margin: EdgeInsets.only(right: 10 * scale),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? color : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14 * scale,
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addNewTask,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.taskHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Provider.of<TodoProvider>(context, listen: false)
                        .addTodo(controller.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37474F),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.addTask,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
