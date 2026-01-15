import 'package:flutter/material.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/screens/calendar_screen.dart';
import 'package:todo_app/screens/grocery_screen.dart';
import 'package:todo_app/screens/todo_list_screen.dart';
import 'package:todo_app/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TodoListScreen(),
    const GroceryScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWideScreen = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
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
                  Image.asset('assets/logo.png', height: 40),
                  const SizedBox(height: 8),
                  Text(
                    l10n.skylight,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Color(0xFF1B5E20), size: 30),
              unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 24),
              selectedLabelTextStyle: TextStyle(
                color: const Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.check_circle_outline),
                  selectedIcon: const Icon(Icons.check_circle),
                  label: Text(l10n.todoTitle),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  selectedIcon: const Icon(Icons.shopping_cart),
                  label: Text(l10n.grocery),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.calendar_today_outlined),
                  selectedIcon: const Icon(Icons.calendar_today),
                  label: Text(l10n.calendar),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(l10n.settings),
                ),
              ],
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
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFF1B5E20).withOpacity(0.2),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.check_circle_outline),
                  selectedIcon: const Icon(Icons.check_circle, color: Color(0xFF1B5E20)),
                  label: l10n.todoTitle,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  selectedIcon: const Icon(Icons.shopping_cart, color: Color(0xFF1B5E20)),
                  label: l10n.grocery,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_today_outlined),
                  selectedIcon: const Icon(Icons.calendar_today, color: Color(0xFF1B5E20)),
                  label: l10n.calendar,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings, color: Color(0xFF1B5E20)),
                  label: l10n.settings,
                ),
              ],
            ),
    );
  }
}
