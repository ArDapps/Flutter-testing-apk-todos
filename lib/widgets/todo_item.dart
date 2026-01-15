
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../providers/font_size_provider.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(bool?)? onStatusChanged;

  const TodoItem({super.key, required this.todo, this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;

    return Dismissible(
      key: Key(todo.id),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 6 * scale),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24 * scale),
        child: Icon(Icons.delete, color: Colors.red, size: 28 * scale),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<TodoProvider>(context, listen: false).deleteTodo(todo.id);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6 * scale),
        decoration: BoxDecoration(
          color: todo.isCompleted ? const Color(0xFFE8F5E9) : Colors.white, // Green tint when done
          borderRadius: BorderRadius.circular(24), // More rounded (no square)
          border: Border.all(
              color: todo.isCompleted ? Colors.green.withValues(alpha: 0.5) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          onTap: () {
            // Click card to toggle
            final newValue = !todo.isCompleted;
            Provider.of<TodoProvider>(context, listen: false).toggleTodoStatus(todo.id);
            if (onStatusChanged != null) {
              onStatusChanged!(newValue);
            }
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
          leading: Transform.scale(
            scale: 1.2 * scale,
            child: Checkbox(
              shape: const CircleBorder(),
              value: todo.isCompleted,
              activeColor: Colors.green, // Green check
              checkColor: Colors.white,
              side: BorderSide(
                  color: todo.isCompleted ? Colors.green : Colors.grey.shade400, width: 2),
              onChanged: (value) {
                Provider.of<TodoProvider>(context, listen: false)
                    .toggleTodoStatus(todo.id);
                if (onStatusChanged != null) {
                  onStatusChanged!(value);
                }
              },
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 16 * scale,
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isCompleted ? Colors.green.shade800 : Colors.black87,
              fontWeight: todo.isCompleted ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          trailing: todo.isCompleted
              ? const Icon(Icons.emoji_events, color: Colors.amber) // Win trophy
              : Container(
                  width: 12 * scale,
                  height: 12 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF9A9A), // Mock priority/category color
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
