import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/screens/calendar_screen.dart';
import 'package:todo_app/screens/grocery_screen.dart';
import 'package:todo_app/screens/dashboard_screen.dart';
import 'package:todo_app/screens/todo_list_screen.dart';
import 'package:todo_app/screens/settings_screen.dart';
import '../providers/font_size_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CalendarScreen(),
    const TodoListScreen(),
    const GroceryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWideScreen = MediaQuery.of(context).orientation == Orientation.landscape;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        minWidth: 110 * scale,
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        extended: false,
                        labelType: NavigationRailLabelType.all,
                        leading: Column(
                          children: [
                            const SizedBox(height: 20),
                            Image.asset('assets/logo.png', height: 100 * scale),
                            const SizedBox(height: 8),
                       
                          ],
                        ),
                        backgroundColor: Colors.white,
                        indicatorShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        selectedIconTheme: IconThemeData(color: const Color(0xFF1B5E20), size: 30 * scale),
                        unselectedIconTheme: IconThemeData(color: Colors.grey, size: 24 * scale),
                        selectedLabelTextStyle: TextStyle(
                          color: const Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                          fontSize: 12 * scale,
                        ),
                        unselectedLabelTextStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12 * scale,
                        ),
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.check_circle_outline),
                            selectedIcon: const Icon(Icons.check_circle),
                            label: Text(l10n.todoTitle),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.calendar_today_outlined),
                            selectedIcon: const Icon(Icons.calendar_today),
                            label: Text(l10n.calendar),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.list_alt_outlined),
                            selectedIcon: const Icon(Icons.list_alt),
                            label: Text(l10n.lists),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            selectedIcon: const Icon(Icons.shopping_cart),
                            label: Text(l10n.grocery),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.settings_outlined),
                            selectedIcon: const Icon(Icons.settings),
                            label: Text(l10n.settings),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          if (isWideScreen)
            const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    );
                  }
                  return TextStyle(
                    fontSize: 12 * scale,
                    color: Colors.black87,
                  );
                }),
              ),
              child: SizedBox(
                height: 80 * scale,
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined, size: 24 * scale),
                      selectedIcon: Icon(Icons.dashboard, size: 24 * scale),
                      label: l10n.organizeTitle,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_today_outlined, size: 24 * scale),
                      selectedIcon: Icon(Icons.calendar_today, size: 24 * scale),
                      label: l10n.calendar,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.list_alt, size: 24 * scale),
                      selectedIcon: Icon(Icons.list, size: 24 * scale),
                      label: l10n.todoTitle,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.shopping_cart_outlined, size: 24 * scale),
                      selectedIcon: Icon(Icons.shopping_cart, size: 24 * scale),
                      label: l10n.grocery,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined, size: 24 * scale),
                      selectedIcon: Icon(Icons.settings, size: 24 * scale),
                      label: l10n.settings,
                    ),
                  ],
                ),
              ),
          )
    );
  }
}
