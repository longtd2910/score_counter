import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:score_counter/l10n/l10n.dart';
import 'package:score_counter/providers/game_provider.dart';
import 'package:score_counter/providers/language_provider.dart';
import 'package:score_counter/screens/game_mode_screen.dart';
import 'package:score_counter/screens/history_screen.dart';
import 'package:score_counter/screens/saved_games_screen.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppBar(
      title: Text(
        L10n.of(context).settings,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    
    return Consumer2<GameProvider, LanguageProvider>(
      builder: (context, gameProvider, languageProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingsCard(
              context,
              title: l10n.gameMode,
              subtitle: l10n.selectOrCreateGameMode,
              icon: Icons.sports,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameModeScreen()),
                );
              },
            ),
            _buildSettingsCard(
              context,
              title: l10n.viewSavedGames,
              subtitle: l10n.seePreviouslySavedGames,
              icon: Icons.folder_open,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedGamesScreen()),
                );
              },
            ),
            _buildSettingsCard(
              context,
              title: l10n.viewGameHistory,
              subtitle: l10n.seeActionsHistoryLog,
              icon: Icons.history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            _buildLanguageCard(
              context,
              languageProvider: languageProvider,
            ),
            _buildSwitchCard(
              context,
              title: l10n.keepScreenAwake,
              subtitle: l10n.preventScreenFromTurningOff,
              icon: Icons.visibility,
              value: gameProvider.keepScreenAwake,
              onChanged: (value) {
                gameProvider.setKeepScreenAwake(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required LanguageProvider languageProvider,
  }) {
    final l10n = L10n.of(context);
    String languageDisplay = languageProvider.useSystemLocale
        ? l10n.systemDefault
        : L10n.getLanguageName(languageProvider.locale?.languageCode ?? 'en');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.language, size: 28),
        title: Text(
          l10n.language,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(l10n.selectLanguage),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(languageDisplay),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _showLanguageSelectionDialog(context, languageProvider),
      ),
    );
  }

  Widget _buildSwitchCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        secondary: Icon(icon, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context, LanguageProvider languageProvider) {
    final l10n = L10n.of(context);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.systemDefault),
                leading: const Icon(Icons.settings_system_daydream),
                selected: languageProvider.useSystemLocale,
                onTap: () {
                  languageProvider.setUseSystemLocale();
                  Navigator.pop(context);
                },
              ),
              ...L10n.supportedLocales.map((locale) {
                return ListTile(
                  title: Text(L10n.getLanguageName(locale.languageCode)),
                  leading: const Icon(Icons.language),
                  selected: !languageProvider.useSystemLocale && 
                            languageProvider.locale?.languageCode == locale.languageCode,
                  onTap: () {
                    languageProvider.setLocale(locale);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}
