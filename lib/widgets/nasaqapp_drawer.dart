
import 'package:flutter/material.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../screens/calendar_screen.dart';
import '../screens/grocery_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/meals_screen.dart';
import '../screens/dashboard_screen.dart';

class NasaqappDrawer extends StatelessWidget {
  const NasaqappDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.organizeDay,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Version 8",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.dashboard_outlined, l10n.organizeTitle, false, () {
               Navigator.pop(context);
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const DashboardScreen()),
               );
            }),
            _buildDrawerItem(context, Icons.check_circle_outline, l10n.todoTitle, false, () {
               Navigator.pop(context);
               Navigator.popUntil(context, (route) => route.isFirst);
            }),
            _buildDrawerItem(context, Icons.shopping_cart_outlined, l10n.grocery, false, () {
               Navigator.pop(context);
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const GroceryScreen()),
               );
            }),
            _buildDrawerItem(context, Icons.restaurant_menu, l10n.menu, false, () {
               Navigator.pop(context);
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const MealsScreen()),
               );
            }),
            _buildDrawerItem(context, Icons.calendar_today, l10n.calendar, false, () {
               Navigator.pop(context);
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const CalendarScreen()),
               );
            }),
            const Divider(),
            _buildDrawerItem(context, Icons.settings_outlined, l10n.settings, false, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? const Color(0xFF1B5E20) : Colors.black87,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
