import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/skylight_drawer.dart';

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: const SkylightDrawer(), // Removed drawer
      appBar: AppBar(
        title: Text(
          l10n.grocery,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        automaticallyImplyLeading: false, // Don't show back button or drawer icon
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.groceries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  Text(
                    l10n.noTasks, // Or maybe a grocery specific message if we had one
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: provider.groceries.length,
            itemBuilder: (context, index) {
              return TodoItem(todo: provider.groceries[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGroceryDialog(context),
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  void _showAddGroceryDialog(BuildContext context) {
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
                l10n.addNewTask, // "Add New Task" - we can reuse this
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.taskHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Provider.of<TodoProvider>(context, listen: false)
                        .addTodo(controller.text, category: 'grocery');
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.addTask,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
