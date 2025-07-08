import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';

class CompactPlayerCard extends StatelessWidget {
  final int playerIndex;

  const CompactPlayerCard({super.key, required this.playerIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final player = gameProvider.players[playerIndex];
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: player.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Player name
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        showDragHandle: true,
                        context: context,
                        builder: (context) => EditPlayerBottomSheet(
                          playerData: player,
                        ),
                        useSafeArea: true,
                        isScrollControlled: true,
                      );
                    },
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                // Controls
                Row(
                  children: [
                    // Minus button
                    IconButton(
                      onPressed: () {
                        gameProvider.updatePlayerScore(playerIndex, -1);
                        HapticFeedback.mediumImpact();
                      },
                      icon: Icon(Icons.remove_circle),
                      iconSize: 28,
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(),
                    ),
                    
                    // Score
                    Container(
                      constraints: BoxConstraints(minWidth: 40),
                      child: Text(
                        player.score.toString(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Plus button
                    IconButton(
                      onPressed: () {
                        gameProvider.updatePlayerScore(playerIndex, 1);
                        HapticFeedback.mediumImpact();
                      },
                      icon: Icon(Icons.add_circle),
                      iconSize: 28,
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EditPlayerBottomSheet extends StatelessWidget {
  final Player playerData;

  const EditPlayerBottomSheet({super.key, required this.playerData});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Find the player by name and color instead of ID
        int playerIndex = gameProvider.players.indexWhere(
          (p) => p.name == playerData.name && p.color == playerData.color
        );
        
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Player',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, gameProvider, playerIndex);
                },
              ),
              ListTile(
                leading: Icon(Icons.color_lens),
                title: Text('Change Color'),
                onTap: () {
                  Navigator.pop(context);
                  _showColorPickerDialog(context, gameProvider, playerIndex);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Player', style: TextStyle(color: Colors.red)),
                onTap: () {
                  gameProvider.removePlayer(playerIndex);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showRenameDialog(BuildContext context, GameProvider gameProvider, int playerIndex) {
    final TextEditingController controller = TextEditingController(text: playerData.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Player'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty && playerIndex >= 0) {
                gameProvider.updatePlayerName(playerIndex, controller.text);
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showColorPickerDialog(BuildContext context, GameProvider gameProvider, int playerIndex) {
    // Access playerColors from the global list imported from player.dart
    int selectedColorIndex = playerColors.indexOf(playerData.color);
    if (selectedColorIndex == -1) selectedColorIndex = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Choose Color'),
            content: Container(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: playerColors.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == selectedColorIndex;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedColorIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: playerColors[index],
                        shape: BoxShape.circle,
                        border: isSelected 
                            ? Border.all(color: Colors.white, width: 2) 
                            : null,
                      ),
                      child: isSelected 
                          ? Icon(Icons.check, color: Colors.white) 
                          : null,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (playerIndex >= 0) {
                    gameProvider.updatePlayerColor(playerIndex, playerColors[selectedColorIndex]);
                  }
                  Navigator.pop(context);
                },
                child: Text('Apply'),
              ),
            ],
          );
        }
      ),
    );
  }
} 