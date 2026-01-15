
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../services/local_storage_service.dart';
import 'package:todo_app/screens/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNext(int totalItems) {
    if (_currentPage < totalItems - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await LocalStorageService().setOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<OnboardingItem> items = [
      OnboardingItem(
        title: l10n.welcomeTitle,
        description: l10n.welcomeDesc,
        icon: Icons.check_circle_outline,
        color: const Color(0xFF1B5E20),
        imageAsset: 'assets/logo.png',
      ),
      OnboardingItem(
        title: l10n.organizeTitle,
        description: l10n.organizeDesc,
        icon: Icons.list_alt,
        color: const Color(0xFF2E7D32),
      ),
      OnboardingItem(
        title: l10n.doneTitle,
        description: l10n.doneDesc,
        icon: Icons.done_all,
        color: const Color(0xFF43A047),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(item: items[index]);
                },
              ),
            ),
            _buildBottomControls(items),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(List<OnboardingItem> items) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicator
          Row(
            children: List.generate(
              items.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? items[_currentPage].color : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Button
          ElevatedButton(
            onPressed: () {
              if (_currentPage == items.length - 1) {
                _finishOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: items[_currentPage].color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _currentPage == items.length - 1 ? l10n.getStarted : l10n.next,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imageAsset;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imageAsset,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const _OnboardingPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item.imageAsset != null
              ? Image.asset(
                  item.imageAsset!,
                  height: 150,
                  fit: BoxFit.contain,
                )
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(delay: 200.ms, duration: 500.ms)
              : Icon(
                  item.icon,
                  size: 150,
                  color: item.color,
                )
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(delay: 200.ms, duration: 500.ms),
          const SizedBox(height: 50),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
