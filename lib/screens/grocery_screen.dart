import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../providers/todo_provider.dart';
import '../providers/font_size_provider.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  late ConfettiController _confettiController;
  late FlutterTts _flutterTts;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
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
    _flutterTts.stop();
    super.dispose();
  }

  void _onTaskCompleted(bool? isCompleted) {
    if (isCompleted == true) {
      _confettiController.play();
      _audioPlayer.play(AssetSource('sounds/clapping.mp3'));
      _flutterTts.speak("Great job!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;

    // Define pastel colors for the cards
    final List<Color> cardColors = [
      const Color(0xFFC8E6C9), // Green 100
      const Color(0xFFDCEDC8), // Light Green 100
      const Color(0xFFF0F4C3), // Lime 100
      const Color(0xFFFFF9C4), // Yellow 100
      const Color(0xFFFFECB3), // Amber 100
      const Color(0xFFFFE0B2), // Orange 100
      const Color(0xFFFFCCBC), // Deep Orange 100
      const Color(0xFFB2DFDB), // Teal 100
    ];
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.grocery,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 24 * scale,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Consumer<TodoProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.groceries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 100 * scale, color: Colors.grey.shade300),
                          const SizedBox(height: 20),
                          Text(
                            l10n.noTasks,
                            style: TextStyle(
                              fontSize: 18 * scale,
                              color: Colors.grey.shade500,
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
                      childAspectRatio: 1.0,
                    ),
                    itemCount: provider.groceries.length,
                    itemBuilder: (context, index) {
                      final todo = provider.groceries[index];
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
                                       Icons.shopping_bag_outlined,
                                       size: 20 * scale,
                                       color: Colors.black54,
                                     ),
                                   ),
                                   if (todo.isCompleted)
                                     Icon(Icons.check_circle, color: Colors.white.withOpacity(0.6), size: 24 * scale),
                                 ],
                               ),
                               Expanded(
                                 child: Center(
                                   child: Text(
                                     todo.title,
                                     style: TextStyle(
                                       fontSize: 18 * scale,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.black87,
                                       decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                     ),
                                     textAlign: TextAlign.center,
                                     maxLines: 3,
                                     overflow: TextOverflow.ellipsis,
                                   ),
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
            
            // Confetti Widget
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGroceryDialog(context),
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddGroceryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);
    final scale = fontSizeProvider.fontScale;

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
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.taskHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Provider.of<TodoProvider>(context, listen: false)
                        .addTodo(controller.text, category: 'grocery');
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.addTask,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
