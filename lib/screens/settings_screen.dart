
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/font_size_provider.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context)!.language,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildLanguageOption(context, 'English', const Locale('en')),
                const Divider(height: 1),
                _buildLanguageOption(context, 'العربية', const Locale('ar')),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            AppLocalizations.of(context)!.fontSize,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Consumer<FontSizeProvider>(
              builder: (context, fontSizeProvider, _) {
                return Column(
                  children: [
                    RadioListTile<double>(
                      title: const Text('1x'),
                      value: 1.0,
                      groupValue: fontSizeProvider.fontScale,
                      onChanged: (value) => fontSizeProvider.setFontScale(value!),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    const Divider(height: 1),
                    RadioListTile<double>(
                      title: const Text('2x'),
                      value: 2.0,
                      groupValue: fontSizeProvider.fontScale,
                      onChanged: (value) => fontSizeProvider.setFontScale(value!),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    const Divider(height: 1),
                    RadioListTile<double>(
                      title: const Text('3x'),
                      value: 3.0,
                      groupValue: fontSizeProvider.fontScale,
                      onChanged: (value) => fontSizeProvider.setFontScale(value!),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await LocalStorageService().clearOnboarding();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.resetOnboardingSuccess,
                      style: TextStyle(),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.resetOnboarding,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, Locale locale) {
    final provider = Provider.of<LocaleProvider>(context);
    final isSelected = provider.locale.languageCode == locale.languageCode;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20))
          : null,
      onTap: () {
        provider.setLocale(locale);
      },
    );
  }
}
