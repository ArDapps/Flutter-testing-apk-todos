import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import '../providers/font_size_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/locale_provider.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
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
            l10n.language,
            style: const TextStyle(
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
          
          // Volume Control
          Text(
            l10n.volume,
            style: const TextStyle(
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Consumer<SoundProvider>(
              builder: (context, soundProvider, child) {
                return Row(
                  children: [
                    Icon(Icons.volume_mute, color: Colors.grey.shade600),
                    Expanded(
                      child: Slider(
                        value: soundProvider.volume,
                        min: 0,
                        max: 1,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          soundProvider.setVolume(value);
                        },
                      ),
                    ),
                    Icon(Icons.volume_up, color: Colors.grey.shade600),
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
                    content: Text(l10n.resetOnboardingSuccess),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.resetOnboarding),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, Locale locale) {
    return Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.locale.languageCode == locale.languageCode;
        return ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
          onTap: () {
            provider.setLocale(locale);
          },
        );
      },
    );
  }
}
