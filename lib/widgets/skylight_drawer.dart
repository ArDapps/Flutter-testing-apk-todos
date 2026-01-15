
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../screens/settings_screen.dart';

class SkylightDrawer extends StatelessWidget {
  const SkylightDrawer({super.key});

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
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.skylight,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.organizeDay,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.check_circle_outline, l10n.todoTitle, true, () {
               Navigator.pop(context); // Already on To Do
            }),
            _buildDrawerItem(context, Icons.shopping_cart_outlined, l10n.grocery, false, () {
               Navigator.pop(context);
            }),
            _buildDrawerItem(context, Icons.calendar_today, l10n.calendar, false, () {
               Navigator.pop(context);
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
        style: GoogleFonts.poppins(
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
