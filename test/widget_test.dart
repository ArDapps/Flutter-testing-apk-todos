
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('Todo list screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is present.
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('No tasks yet!'), findsOneWidget);
  });
}
