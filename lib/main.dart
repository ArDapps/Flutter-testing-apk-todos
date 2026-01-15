
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'providers/todo_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              fontFamily: 'IBMPlexSansArabic',
              primarySwatch: Colors.green,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
