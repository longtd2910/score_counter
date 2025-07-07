import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../models/game_mode.dart';
import '../providers/game_provider.dart';
import '../screens/score_screen.dart';
import '../widgets/create_game_mode_dialog.dart';

class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).chooseGameMode),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          // Sort game modes with favorites first
          final gameModes = List<GameMode>.from(gameProvider.gameModes);
          gameModes.sort((a, b) {
            if (a.favourite == b.favourite) {
              return 0;
            }
            return a.favourite ? -1 : 1;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gameModes.length + 1, // +1 for the "Create New Mode" button
            itemBuilder: (context, index) {
              if (index == gameModes.length) {
                // Create New Mode button at the end
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.add_circle),
                    title: Text(L10n.of(context).createNewGameMode),
                    onTap: () => _showCreateGameModeDialog(context),
                  ),
                );
              }

              final gameMode = gameModes[index];
              final locale = Localizations.localeOf(context);
              final languageCode = locale.languageCode;

              return Card(
                child: ListTile(
                  leading: Icon(
                    gameMode.favourite ? Icons.star : Icons.star_border,
                    color: gameMode.favourite ? Colors.amber[500]! : null,
                  ),
                  title: Text(gameMode.getLocalizedTitle(languageCode)),
                  subtitle: Text(
                    gameMode.countableObjects
                        .map((obj) => '${obj.ballNumber} (${obj.score} pts)')
                        .join(', '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    gameProvider.setCurrentGameMode(gameMode);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScoreScreen(
                        gameProvider: gameProvider,
                      )),
                    );
                  },
                  onLongPress: () {
                    gameProvider.toggleFavorite(gameProvider.gameModes.indexOf(gameMode));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateGameModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateGameModeDialog(),
    );
  }
} 