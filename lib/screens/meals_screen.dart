import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../widgets/nasaqapp_drawer.dart';
import '../providers/font_size_provider.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final scale = fontSizeProvider.fontScale;

    final List<Map<String, dynamic>> meals = [
      {
        'title': l10n.mealPancakes,
        'icon': Icons.breakfast_dining,
        'calories': 350,
        'ingredients': l10n.pancakesIngredients,
        'instructions': l10n.pancakesInstructions,
      },
      {
        'title': l10n.mealSalad,
        'icon': Icons.lunch_dining,
        'calories': 200,
        'ingredients': l10n.saladIngredients,
        'instructions': l10n.saladInstructions,
      },
      {
        'title': l10n.mealPasta,
        'icon': Icons.dinner_dining,
        'calories': 600,
        'ingredients': l10n.pastaIngredients,
        'instructions': l10n.pastaInstructions,
      },
    ];

    return Scaffold(
      drawer: const NasaqappDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          l10n.menu,
          style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16 * scale),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 16 * scale),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      meal['title'],
                      style: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(meal['icon'], size: 80 * scale, color: Theme.of(context).primaryColor),
                          SizedBox(height: 20 * scale),
                          _buildDetailSection(l10n.ingredients, meal['ingredients'], scale),
                          SizedBox(height: 16 * scale),
                          _buildDetailSection(l10n.instructions, meal['instructions'], scale),
                          SizedBox(height: 16 * scale),
                          Container(
                            padding: EdgeInsets.all(8 * scale),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${l10n.calories}: ${meal['calories']}',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.close, style: TextStyle(fontSize: 16 * scale)),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(meal['icon'], size: 32 * scale, color: Colors.blue),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal['title'],
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            '${meal['calories']} ${l10n.calories}',
                            style: TextStyle(
                              fontSize: 14 * scale,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16 * scale, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, double scale) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          content,
          style: TextStyle(
            fontSize: 16 * scale,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
