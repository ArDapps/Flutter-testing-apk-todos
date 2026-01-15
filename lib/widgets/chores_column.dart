import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/font_size_provider.dart';

class ChoresColumn extends StatelessWidget {
  final List<Todo> chores;
  final Function(Todo, bool) onChoreToggled;

  const ChoresColumn({
    super.key,
    required this.chores,
    required this.onChoreToggled,
  });

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 300 * scale,
      margin: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5FE), // Light blue background
        borderRadius: BorderRadius.circular(32 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cleaning_services, color: Colors.blue, size: 24 * scale),
              ),
              SizedBox(width: 12 * scale),
              Text(
                l10n.chores,
                style: TextStyle(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * scale),

          // Chores List
          Expanded(
            child: ListView.builder(
              itemCount: chores.length,
              itemBuilder: (context, index) {
                final chore = chores[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12 * scale),
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon/Emoji placeholder
                      Container(
                        padding: EdgeInsets.all(8 * scale),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_laundry_service, color: Colors.blue, size: 20 * scale),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Text(
                          chore.title,
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            decoration: chore.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Switch(
                        value: chore.isCompleted,
                        onChanged: (value) => onChoreToggled(chore, value),
                        activeTrackColor: Colors.blue,
                        thumbColor: WidgetStateProperty.all(Colors.white),
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
