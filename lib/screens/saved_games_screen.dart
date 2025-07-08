import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:score_counter/l10n/l10n.dart';
import 'package:score_counter/providers/game_provider.dart';
import 'package:score_counter/screens/saved_game_details_screen.dart';
import 'package:score_counter/screens/score_screen.dart';
import 'package:score_counter/models/saved_game.dart';
import 'package:intl/intl.dart';

class SavedGamesScreen extends StatefulWidget {
  const SavedGamesScreen({super.key});

  @override
  State<SavedGamesScreen> createState() => _SavedGamesScreenState();
}

class _SavedGamesScreenState extends State<SavedGamesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedGames();
  }

  Future<void> _loadSavedGames() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    await gameProvider.loadSavedGames();
    setState(() {
      _isLoading = false;
    });
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Today, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDayTitle(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d').format(dateTime); // Example: "Monday, Jan 15"
    }
  }

  // Helper function to check if two player lists have same names and scores
  bool _arePlayersIdentical(List<SavedGame> games) {
    if (games.isEmpty) return false;
    if (games.length == 1) return true;
    
    final firstGame = games.first;
    
    for (final game in games.skip(1)) {
      // Check if the player count is different
      if (game.players.length != firstGame.players.length) {
        return false;
      }
      
      // Check each player name and score
      for (int i = 0; i < game.players.length; i++) {
        bool foundMatch = false;
        
        // Find matching player by name
        for (final firstPlayer in firstGame.players) {
          if (game.players[i].name == firstPlayer.name && 
              game.players[i].score == firstPlayer.score) {
            foundMatch = true;
            break;
          }
        }
        
        if (!foundMatch) {
          return false;
        }
      }
    }
    
    return true;
  }

  // Group saved games by player names and scores
  List<List<SavedGame>> _groupSavedGames(List<SavedGame> games) {
    final List<List<SavedGame>> groupedGames = [];
    final Map<String, List<SavedGame>> gamesByPlayersKey = {};
    
    // Create a unique key for each game based on player names and scores
    for (final game in games) {
      final sortedPlayers = [...game.players];
      sortedPlayers.sort((a, b) => a.name.compareTo(b.name));
      
      final key = sortedPlayers.map((p) => '${p.name}:${p.score}').join('|');
      
      if (!gamesByPlayersKey.containsKey(key)) {
        gamesByPlayersKey[key] = [];
      }
      gamesByPlayersKey[key]!.add(game);
    }
    
    // Convert map to list of groups
    groupedGames.addAll(gamesByPlayersKey.values);
    
    // Sort groups by most recent timestamp
    groupedGames.sort((a, b) {
      final latestA = a.map((g) => g.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);
      final latestB = b.map((g) => g.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);
      return latestB.compareTo(latestA);
    });
    
    return groupedGames;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          title: Text(
            L10n.of(context).savedGames,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  if (gameProvider.savedGames.isEmpty) {
                    return Center(
                      child: Text(
                        L10n.of(context).noSavedGamesYet,
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final groupedGames = _groupSavedGames(gameProvider.savedGames);
      
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: groupedGames.length,
                    itemBuilder: (context, index) {
                      final gameGroup = groupedGames[index];
                      final latestGame = gameGroup.reduce(
                        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b
                      );
                      
                      // Sort timestamps in descending order
                      final timestamps = gameGroup.map((g) => g.timestamp).toList()
                        ..sort((a, b) => b.compareTo(a));
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                _formatDayTitle(latestGame.timestamp),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    latestGame.gameMode.title["vi"] ?? 
                                    latestGame.gameMode.title["en"] ?? 
                                    "Game"
                                  ),
                                  Text(
                                    'Saved: ${timestamps.map((t) => _formatTime(t)).join(", ")}',
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    tooltip: 'Load game',
                                    onPressed: () async {
                                      await gameProvider.loadSavedGame(latestGame.id);
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ScoreScreen(gameProvider: gameProvider),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Delete saved game',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(L10n.of(context).deleteSavedGames),
                                          content: Text(
                                            gameGroup.length > 1 
                                              ? L10n.of(context).deleteConfirmMultiple(gameGroup.length)
                                              : L10n.of(context).deleteConfirmSingle,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(L10n.of(context).cancel),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                // Delete all games in the group
                                                for (final game in gameGroup) {
                                                  await gameProvider.deleteSavedGame(game.id);
                                                }
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Text(
                                                L10n.of(context).delete,
                                                style: const TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SavedGameDetailsScreen(savedGame: latestGame),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: latestGame.players.map((player) {
                                  return Chip(
                                    label: Text(
                                      '${player.name}: ${player.score}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    backgroundColor: player.color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
} 