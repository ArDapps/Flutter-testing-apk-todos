
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../providers/todo_provider.dart';
import '../providers/font_size_provider.dart';
import '../widgets/todo_item.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header & Filters (Skylight Style)
            Container(
              padding: EdgeInsets.all(20 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.todoTitle,
                        style: TextStyle(
                          fontSize: 32 * scale,
                          fontFamily: 'IBMPlexSansArabic',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // Add Button (Pill shape like Calendar)
                      ElevatedButton.icon(
                        onPressed: () => _showAddTodoDialog(context),
                        icon: Icon(Icons.add, size: 18 * scale),
                        label: Text(l10n.addTask, style: TextStyle(fontSize: 14 * scale)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF37474F), // Dark slate
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * scale),
                  // Mock Filters/Categories
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                         _buildCategoryPill("All", Colors.black87, true, scale),
                         _buildCategoryPill("Personal", const Color(0xFFEF9A9A), false, scale),
                         _buildCategoryPill("Work", const Color(0xFF90CAF9), false, scale),
                         _buildCategoryPill("Grocery", const Color(0xFFA5D6A7), false, scale),
                         _buildCategoryPill("Family", const Color(0xFFFFCC80), false, scale),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. Task List
            Expanded(
              child: Consumer<TodoProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.generalTodos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 100 * scale, color: Colors.grey.shade200),
                          const SizedBox(height: 20),
                          Text(
                            l10n.noTasks,
                            style: TextStyle(
                              fontSize: 18 * scale,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 0),
                    itemCount: provider.generalTodos.length,
                    itemBuilder: (context, index) {
                      return TodoItem(todo: provider.generalTodos[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // FAB removed in favor of Header button
    );
  }

  Widget _buildCategoryPill(String label, Color color, bool isSelected, double scale) {
    return Container(
      margin: EdgeInsets.only(right: 10 * scale),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? color : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14 * scale,
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addNewTask,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.taskHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Provider.of<TodoProvider>(context, listen: false)
                        .addTodo(controller.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37474F),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.addTask,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
