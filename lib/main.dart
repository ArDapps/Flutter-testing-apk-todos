
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'providers/todo_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/todo_list_screen.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSeenOnboarding = await LocalStorageService().hasSeenOnboarding();
  
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Nasaq',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            theme: ThemeData(
              primarySwatch: Colors.green,
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
              useMaterial3: true,
            ),
            home: hasSeenOnboarding ? const TodoListScreen() : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
