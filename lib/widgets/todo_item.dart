
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<TodoProvider>(context, listen: false).deleteTodo(todo.id);
      },
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: Transform.scale(
              scale: 1.2,
              child: Checkbox(
                shape: const CircleBorder(),
                value: todo.isCompleted,
                activeColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade400, width: 2),
                onChanged: (value) {
                  Provider.of<TodoProvider>(context, listen: false)
                      .toggleTodoStatus(todo.id);
                },
              ),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                fontSize: 16,
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1, indent: 70),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}
