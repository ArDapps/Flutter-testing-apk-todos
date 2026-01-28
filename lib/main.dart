
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'providers/todo_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/font_size_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/update_provider.dart';
import 'providers/wifi_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TodoProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
          ChangeNotifierProvider(create: (_) => SoundProvider()),
          ChangeNotifierProvider(create: (_) => UpdateProvider()),
          ChangeNotifierProvider(create: (_) => WifiProvider()),
        ],
        child: Consumer2<LocaleProvider, FontSizeProvider>(
          builder: (context, localeProvider, fontSizeProvider, child) {
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
              iconTheme: IconThemeData(
                size: 24.0 * fontSizeProvider.fontScale,
              ),
            ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(fontSizeProvider.fontScale),
                ),
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
      ),
    );
  }
}
