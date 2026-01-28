// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Todo App';

  @override
  String get todoTitle => 'To Do';

  @override
  String get noTasks => 'No tasks yet!';

  @override
  String get addNewTask => 'Add New Task';

  @override
  String get taskHint => 'What needs to be done?';

  @override
  String get addTask => 'Add Task';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get fontSize => 'Font Size';

  @override
  String get grocery => 'Grocery';

  @override
  String get calendar => 'Calendar';

  @override
  String get nasaqapp => 'NasaqApp';

  @override
  String get organizeDay => 'Organize your day';

  @override
  String get welcomeTitle => 'Welcome to Nasaq';

  @override
  String get welcomeDesc => 'Manage your tasks efficiently and effectively.';

  @override
  String get organizeTitle => 'Stay Organized';

  @override
  String get organizeDesc =>
      'Group your tasks and keep track of your progress.';

  @override
  String get doneTitle => 'Get Things Done';

  @override
  String get doneDesc =>
      'Achieve your goals with our simple and intuitive interface.';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get delete => 'Delete';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get resetOnboardingSuccess =>
      'Onboarding reset! Restart app to see it.';

  @override
  String get gregorian => 'Gregorian';

  @override
  String get hijri => 'Hijri';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get chores => 'Chores';

  @override
  String get filter => 'Filter';

  @override
  String get today => 'Today';

  @override
  String get assignTo => 'Assign to...';

  @override
  String get personalTask => 'Personal Task';

  @override
  String get sharedChore => 'Shared Chore';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get rewards => 'Rewards';

  @override
  String get meals => 'Meals';

  @override
  String get photos => 'Photos';

  @override
  String get lists => 'Lists';

  @override
  String get sleep => 'Sleep';

  @override
  String get volume => 'Volume';

  @override
  String get addEvent => 'Add Event';

  @override
  String get eventTitle => 'Event Title';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get close => 'Close';

  @override
  String get family => 'Family';

  @override
  String get birthdays => 'Birthdays';

  @override
  String get holidays => 'Holidays';

  @override
  String get menu => 'Menu';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String get calories => 'Calories';

  @override
  String get mealPancakes => 'Pancakes';

  @override
  String get mealSalad => 'Chicken Salad';

  @override
  String get mealPasta => 'Pasta Alfredo';

  @override
  String get pancakesIngredients => 'Flour, Milk, Eggs, Sugar';

  @override
  String get pancakesInstructions => 'Mix ingredients and cook on pan.';

  @override
  String get saladIngredients => 'Lettuce, Chicken, Tomatoes, Dressing';

  @override
  String get saladInstructions => 'Chop vegetables and mix with chicken.';

  @override
  String get pastaIngredients => 'Pasta, Cream, Cheese, Butter';

  @override
  String get pastaInstructions => 'Boil pasta and mix with sauce.';

  @override
  String get updates => 'Updates';

  @override
  String get autoUpdate => 'Auto Update';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get checkingForUpdates => 'Checking for updates...';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get noUpdateAvailable => 'No update available';

  @override
  String get downloading => 'Downloading...';

  @override
  String get install => 'Install';

  @override
  String currentVersion(Object version) {
    return 'Current Version: $version';
  }
}
