import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../models/profile.dart';
import '../models/todo.dart';
import '../providers/font_size_provider.dart';

class ProfileColumn extends StatelessWidget {
  final Profile profile;
  final List<Todo> todos;
  final VoidCallback onAddPressed;
  final Function(Todo, bool) onTaskCompleted;

  const ProfileColumn({
    super.key,
    required this.profile,
    required this.todos,
    required this.onAddPressed,
    required this.onTaskCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;
    final l10n = AppLocalizations.of(context)!;
    
    final completedCount = todos.where((t) => t.isCompleted).length;
    final totalCount = todos.length;

    return Container(
      width: 300 * scale,
      margin: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 24 * scale,
                backgroundColor: profile.color,
                child: Text(
                  profile.initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * scale,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    // Progress Pill
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12 * scale, color: Colors.black54),
                          SizedBox(width: 4 * scale),
                          Text(
                            '$completedCount/$totalCount',
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Star/Points Pill (Mock)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), // Light orange
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16 * scale, color: Colors.orange),
                    SizedBox(width: 4 * scale),
                    Text(
                      '10',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * scale),
          
          // Time of day icons (Mock)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeIcon(Icons.wb_sunny_outlined, true, profile.color, scale),
              _buildTimeIcon(Icons.wb_twilight, false, profile.color, scale),
              _buildTimeIcon(Icons.nights_stay_outlined, false, profile.color, scale),
              _buildTimeIcon(Icons.cleaning_services_outlined, false, profile.color, scale),
            ],
          ),
          SizedBox(height: 20 * scale),
          
          Text(
            l10n.morning,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12 * scale),

          // Tasks Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12 * scale,
                mainAxisSpacing: 12 * scale,
                childAspectRatio: 1.0,
              ),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                // Simple color rotation based on index
                final color = [
                  const Color(0xFFFFCDD2), const Color(0xFFF8BBD0),
                  const Color(0xFFE1BEE7), const Color(0xFFD1C4E9),
                  const Color(0xFFC5CAE9), const Color(0xFFBBDEFB),
                ][index % 6];

                return GestureDetector(
                  onTap: () => onTaskCompleted(todo, !todo.isCompleted),
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
                            Icon(
                              todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              size: 16 * scale,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
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
          
          SizedBox(height: 10 * scale),
          
          // Add Button
          Center(
            child: IconButton(
              onPressed: onAddPressed,
              icon: Icon(Icons.add_circle, color: profile.color, size: 48 * scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeIcon(IconData icon, bool isSelected, Color color, double scale) {
    return Container(
      width: 40 * scale,
      height: 40 * scale,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: isSelected ? Border.all(color: color, width: 2) : null,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isSelected ? color : Colors.grey.shade400,
        size: 20 * scale,
      ),
    );
  }
}
