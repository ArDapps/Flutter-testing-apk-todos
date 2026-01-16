
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../providers/todo_provider.dart';
import '../providers/font_size_provider.dart';
import '../models/todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late ConfettiController _confettiController;
  late FlutterTts _flutterTts;
  late AudioPlayer _audioPlayer;
  String _selectedCategory = 'All';

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
    
    // Define pastel colors for the cards
    final List<Color> cardColors = [
      const Color(0xFFFFCDD2), // Red 100
      const Color(0xFFF8BBD0), // Pink 100
      const Color(0xFFE1BEE7), // Purple 100
      const Color(0xFFD1C4E9), // Deep Purple 100
      const Color(0xFFC5CAE9), // Indigo 100
      const Color(0xFFBBDEFB), // Blue 100
      const Color(0xFFB3E5FC), // Light Blue 100
      const Color(0xFFB2EBF2), // Cyan 100
      const Color(0xFFB2DFDB), // Teal 100
      const Color(0xFFC8E6C9), // Green 100
      const Color(0xFFDCEDC8), // Light Green 100
      const Color(0xFFF0F4C3), // Lime 100
      const Color(0xFFFFF9C4), // Yellow 100
      const Color(0xFFFFECB3), // Amber 100
      const Color(0xFFFFE0B2), // Orange 100
      const Color(0xFFFFCCBC), // Deep Orange 100
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  // 1. Header & Filters
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
                            ElevatedButton.icon(
                              onPressed: () => _showAddTodoDialog(context),
                              icon: Icon(Icons.add, size: 18 * scale),
                              label: Text(l10n.addTask, style: TextStyle(fontSize: 14 * scale)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20 * scale),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                               _buildCategoryPill("All", Colors.black87, _selectedCategory == 'All', scale),
                               _buildCategoryPill("Personal", const Color(0xFFEF9A9A), _selectedCategory == 'Personal', scale),
                               _buildCategoryPill("Chores", const Color(0xFF90CAF9), _selectedCategory == 'Chores', scale),
                               _buildCategoryPill("Grocery", const Color(0xFFA5D6A7), _selectedCategory == 'Grocery', scale),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 2. Task Grid
                  Expanded(
                    child: Consumer<TodoProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Filter tasks based on selection
                        List<Todo> todosToShow;
                        if (_selectedCategory == 'All') {
                          todosToShow = provider.todos;
                        } else if (_selectedCategory == 'Personal') {
                          todosToShow = provider.todos.where((t) => t.category == 'general' || t.category == 'personal').toList();
                        } else if (_selectedCategory == 'Chores') {
                          todosToShow = provider.todos.where((t) => t.category == 'chore').toList();
                        } else if (_selectedCategory == 'Grocery') {
                          todosToShow = provider.todos.where((t) => t.category == 'grocery').toList();
                        } else {
                          todosToShow = provider.todos;
                        }

                        if (todosToShow.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.grid_view, size: 100 * scale, color: Colors.grey.shade200),
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

                        // Determine crossAxisCount based on screen width
                        int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;

                        return GridView.builder(
                          padding: EdgeInsets.all(20 * scale),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16 * scale,
                            mainAxisSpacing: 16 * scale,
                            childAspectRatio: 1.0, // Square cards
                          ),
                          itemCount: todosToShow.length,
                          itemBuilder: (context, index) {
                            final todo = todosToShow[index];
                            final color = cardColors[index % cardColors.length];
                            
                            return GestureDetector(
              onTap: () {
                final wasCompleted = todo.isCompleted;
                provider.toggleTodoStatus(todo.id);
                _onTaskCompleted(!wasCompleted);
              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(24 * scale),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(16 * scale),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8 * scale),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            todo.isCompleted ? Icons.check : Icons.circle_outlined,
                                            size: 20 * scale,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        if (todo.isCompleted)
                                          Icon(Icons.check_circle, color: Colors.white.withOpacity(0.6), size: 24 * scale),
                                      ],
                                    ),
                                    Text(
                                      todo.title,
                                      style: TextStyle(
                                        fontSize: 18 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      todo.category.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black45,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Confetti Widget
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow,
                ],
                createParticlePath: _drawStar,
                emissionFrequency: 0.1,
                numberOfParticles: 100,
                gravity: 0.3,
                minBlastForce: 30,
                maxBlastForce: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String label, Color color, bool isSelected, double scale) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
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
