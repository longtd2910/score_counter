import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:score_counter/l10n/l10n.dart';
import 'package:score_counter/providers/game_provider.dart';
import 'package:score_counter/screens/history_screen.dart';
import 'package:score_counter/screens/settings_screen.dart';
import 'package:score_counter/widgets/add_player_dialog.dart';
import 'package:score_counter/widgets/player_card.dart';
import 'package:score_counter/widgets/compact_player_card.dart'; // Import the new widget

class ScoreScreen extends StatefulWidget {
  final GameProvider gameProvider;

  const ScoreScreen({super.key, required this.gameProvider});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  PreferredSizeWidget _buildAppBar() {
    switch (_currentIndex) {
      case 0:
        return ScoreAppBar();
      case 1:
        return HistoryAppBar();
      case 2:
        return SettingsAppBar();
      default:
        return ScoreAppBar();
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return ScoreBody();
      case 1:
        return HistoryScreen();
      case 2:
        return SettingsScreen();
      default:
        return ScoreBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        height: 60,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.scoreboard_outlined),
            label: L10n.of(context).scoreCounter,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: L10n.of(context).history,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: L10n.of(context).settings,
          ),
        ],
        backgroundColor: colorScheme.surface,
        elevation: 2,
        onDestinationSelected: _onDestinationSelected,
        selectedIndex: _currentIndex,
      ),
    );
  }
}

class ScoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScoreAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final players = gameProvider.players;
          if (players.isEmpty) {
            return Text(
              gameProvider.currentGameMode!.title["vi"]!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          }

          // Calculate sum of scores
          final sum = players.fold(0, (total, player) => total + player.score);

          // If sum is not 0, display the sum
          if (sum != 0) {
            return Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.functions_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sum.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[300],
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            );
          } else {
            // If sum is 0, find the player(s) with highest score
            if (players.isEmpty) {
              return Text(
                gameProvider.currentGameMode!.title["vi"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            }
            
            int highestScore = players.map((p) => p.score).reduce((a, b) => a > b ? a : b);
            List<String> highestScorePlayers = players
                .where((p) => p.score == highestScore)
                .map((p) => p.name)
                .toList();

            String displayText = highestScorePlayers.length == 1 
                ? highestScorePlayers[0] 
                : "=";
            
            IconData iconData = highestScorePlayers.length == 1
                ? Icons.emoji_events_rounded  // Trophy for single winner
                : Icons.balance_rounded;  // Balance/scale for tie

            return Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconData,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    displayText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.grey[850],
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }
        },
      ),
      actions: [
        IconButton(
          onPressed: () async {
            final success = await Provider.of<GameProvider>(
              context,
              listen: false,
            ).undoLastAction();
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No action to undo or action cannot be undone'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          icon: const Icon(Icons.undo_rounded),
        ),
        IconButton(
          onPressed: () {
            // Save current game
            final gameProvider = Provider.of<GameProvider>(context, listen: false);
            gameProvider.saveCurrentGame();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Game saved successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.save_rounded),
          tooltip: 'Save game',
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 400),
                child: AlertDialog(
                  title: const Text('Do you want to reset the score?'),
                  content: const Text('This game is auto-saved.'),
                  contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Cancel'),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Provider.of<GameProvider>(context, listen: false).startNewGame();
                                Navigator.of(context).pop();
                              },
                              child: const Text('New game'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Provider.of<GameProvider>(context, listen: false).resetScores();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Reset score'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          icon: const Icon(Icons.restart_alt_rounded),
        ),
        IconButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AddPlayerDialog(),
          ),
          icon: const Icon(Icons.add_box_outlined),
        ),
      ],
    );
  }
}

class ScoreBody extends StatelessWidget {
  const ScoreBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final playerCount = gameProvider.players.length;
        final useCompactLayout = playerCount >= 5;
        
        return SafeArea(
          child: Column(
            spacing: 16,
            children: [
              if (useCompactLayout)
                // Use compact layout for 5 or more players
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: playerCount,
                    itemBuilder: (context, index) {
                      return CompactPlayerCard(playerIndex: index);
                    },
                  ),
                )
              else
                // Use regular layout for 4 or fewer players
                for (var i = 0; i < playerCount; i++)
                  PlayerCard(playerIndex: i),
              SizedBox(height: 2),
            ],
          ),
        );
      },
    );
  }
}
