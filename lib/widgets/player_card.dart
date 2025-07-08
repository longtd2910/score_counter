import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:score_counter/models/player.dart';
import 'package:score_counter/providers/game_provider.dart';
import 'package:score_counter/widgets/action_bar.dart';

class PlayerCard extends StatelessWidget {
  final int playerIndex;

  const PlayerCard({super.key, required this.playerIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Check if we have 4 or more players
        final bool showActionBar = gameProvider.players.length < 4;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: gameProvider.players[playerIndex].color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlayerCardHeader(playerData: gameProvider.players[playerIndex]),
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: double.infinity,
                            child: InkWell(
                              onTap: () => gameProvider.updatePlayerScore(
                                playerIndex,
                                -1,
                              ),
                              child: Icon(Icons.remove),
                            ),
                          ),
                          Center(
                            child: Text(
                              gameProvider.players[playerIndex].score
                                  .toString(),
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: double.infinity,
                            child: InkWell(
                              onTap: () => gameProvider.updatePlayerScore(
                                playerIndex,
                                1,
                              ),
                              child: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTapUp: (details) {
                            final touchX = details.localPosition.dx;
                            final mid = MediaQuery.of(context).size.width / 2;
                            if (touchX < mid) {
                              gameProvider.updatePlayerScore(playerIndex, -1);
                            } else {
                              gameProvider.updatePlayerScore(playerIndex, 1);
                            }
                            HapticFeedback.vibrate();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Only show the ActionBar if we have fewer than 4 players
                if (showActionBar)
                  ActionBar(
                    gameMode: gameProvider.currentGameMode!,
                    changeScoreCallback: (ballNumber) =>
                        gameProvider.updatePlayerScore(playerIndex, ballNumber),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PlayerCardHeader extends StatelessWidget {
  final Player playerData;

  const PlayerCardHeader({super.key, required this.playerData});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        onTap: () {
          showModalBottomSheet(
            showDragHandle: true,
            context: context,
            builder: (context) => EditPlayerDialog(
              playerData: playerData,
              initialColorIndex: playerColors.indexOf(playerData.color),
            ),
            useSafeArea: true,
            isScrollControlled: true,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1)),
          child: Center(
            child: Text(
              playerData.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditPlayerDialog extends StatefulWidget {
  final Player playerData;
  final int initialColorIndex;

  const EditPlayerDialog({
    super.key,
    required this.playerData,
    required this.initialColorIndex,
  });

  @override
  State<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<EditPlayerDialog> {
  late int selectedColorIndex;
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedColorIndex = widget.initialColorIndex;
    nameController.text = widget.playerData.name;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: TextField(controller: nameController),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: playerColors.length,
                itemBuilder: (context, index) {
                  if (index == selectedColorIndex) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: playerColors[index],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedColorIndex = index;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: playerColors[index]),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 56,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    overlayColor: Colors.white.withValues(alpha: 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: () {
                    gameProvider.updatePlayerColor(
                      gameProvider.players.indexOf(widget.playerData),
                      playerColors[selectedColorIndex],
                    );
                    gameProvider.updatePlayerName(
                      gameProvider.players.indexOf(widget.playerData),
                      nameController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 56,
                child: TextButton(
                  onPressed: () {
                    gameProvider.deletePlayer(gameProvider.players.indexOf(widget.playerData));
                    Navigator.pop(context);
                  },
                  child: Text('Delete Player', style: TextStyle(color: Colors.red)),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
