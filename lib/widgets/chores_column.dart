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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),

          // Chores List
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              // Removed shrinkWrap and physics
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12 * scale,
                mainAxisSpacing: 12 * scale,
                childAspectRatio: 1.0,
              ),
              itemCount: chores.length,
              itemBuilder: (context, index) {
                final chore = chores[index];
                // Blue/Cyan/Teal color palette for chores
                final color = [
                  const Color(0xFFB3E5FC), // Light Blue 100
                  const Color(0xFFB2EBF2), // Cyan 100
                  const Color(0xFFB2DFDB), // Teal 100
                  const Color(0xFFE1F5FE), // Light Blue 50
                  const Color(0xFFE0F7FA), // Cyan 50
                  const Color(0xFFE0F2F1), // Teal 50
                ][index % 6];

                return GestureDetector(
                  onTap: () => onChoreToggled(chore, !chore.isCompleted),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6 * scale),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                chore.isCompleted ? Icons.check : Icons.cleaning_services_outlined,
                                size: 16 * scale,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            if (chore.isCompleted)
                              Icon(Icons.check_circle, color: Colors.white.withOpacity(0.6), size: 20 * scale),
                          ],
                        ),
                        Text(
                          chore.title,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            decoration: chore.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
