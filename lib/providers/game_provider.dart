import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../models/history_entry.dart';
import '../models/saved_game.dart';
import '../services/storage_service.dart';
import 'package:live_activities/live_activities.dart';

class GameProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final LiveActivities _liveActivities = LiveActivities();

  List<GameMode> _gameModes = [];
  GameMode? _currentGameMode;
  List<Player> _players = [];
  List<HistoryEntry> _history = [];
  List<SavedGame> _savedGames = [];
  bool _keepScreenAwake = true;

  List<GameMode> get gameModes => _gameModes;
  GameMode? get currentGameMode => _currentGameMode;
  List<Player> get players => _players;
  List<HistoryEntry> get history => _history;
  List<SavedGame> get savedGames => _savedGames;
  bool get keepScreenAwake => _keepScreenAwake;

  bool get isScoreBalanced =>
      _players.isEmpty ||
      _players.fold(0, (sum, player) => sum + player.score) == 0;

  // Initialize game state
  Future<void> init() async {
    _liveActivities.init(appGroupId: 'group.com.example.score_counter');

    _gameModes = await _storageService.getGameModes();
    final currentGame = await _storageService.getCurrentGame();
    _history = await _storageService.getHistoryEntries();
    _savedGames = await _storageService.getSavedGames();

    // Load screen wake lock setting
    final prefs = await SharedPreferences.getInstance();
    _keepScreenAwake = prefs.getBool('keep_screen_awake') ?? true;

    // Apply screen wake lock if enabled
    if (_keepScreenAwake) {
      WakelockPlus.enable();
    }

    if (currentGame != null) {
      _currentGameMode = currentGame['game_mode'] as GameMode;
      _players = List<Player>.from(currentGame['players'] as List);
    }

    notifyListeners();
  }

  // Game mode operations
  void setCurrentGameMode(GameMode gameMode) {
    _currentGameMode = gameMode;
    _players = []; // Reset players when changing game mode
    _saveCurrentGame();
    notifyListeners();
  }

  Future<void> addGameMode(GameMode gameMode) async {
    _gameModes.add(gameMode);
    await _storageService.saveGameModes(_gameModes);
    notifyListeners();
  }

  Future<void> updateGameMode(int index, GameMode updatedGameMode) async {
    if (index >= 0 && index < _gameModes.length) {
      _gameModes[index] = updatedGameMode;
      await _storageService.saveGameModes(_gameModes);

      // Update current game mode if it's the one being updated
      if (_currentGameMode != null &&
          _currentGameMode!.title == _gameModes[index].title) {
        _currentGameMode = updatedGameMode;
        _saveCurrentGame();
      }

      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int index) async {
    if (index >= 0 && index < _gameModes.length) {
      final gameMode = _gameModes[index];
      gameMode.favourite = !gameMode.favourite;
      await _storageService.saveGameModes(_gameModes);
      notifyListeners();
    }
  }

  // Player operations
  Future<void> addPlayer(String name) async {
    for (var color in playerColors) {
      if (!_players.any((player) => player.color == color)) {
        final player = Player(name: name, color: color);
        _players.add(player);

        // Log the action
        final entry = HistoryEntry(
          timestamp: DateTime.now(),
          actionType: ActionType.playerAdded,
          playerName: name,
          playerColor: color,
        );
        await _addHistoryEntry(entry);
        break;
      }
    }

    _saveCurrentGame();
    notifyListeners();
  }

  Future<void> removePlayer(int index) async {
    if (index >= 0 && index < _players.length) {
      final player = _players[index];

      // Log the action
      final entry = HistoryEntry(
        timestamp: DateTime.now(),
        actionType: ActionType.playerRemoved,
        playerName: player.name,
        playerColor: player.color,
      );
      await _addHistoryEntry(entry);

      _players.removeAt(index);
      _saveCurrentGame();
      notifyListeners();
    }
  }

  Future<void> updatePlayerName(int index, String newName) async {
    if (index >= 0 && index < _players.length) {
      final player = _players[index];
      final oldName = player.name;
      player.name = newName;

      // Log the action
      final entry = HistoryEntry(
        timestamp: DateTime.now(),
        actionType: ActionType.playerUpdated,
        playerName: newName,
        playerColor: player.color,
        additionalInfo: ": Name changed from '$oldName' to '$newName'",
      );
      await _addHistoryEntry(entry);

      _saveCurrentGame();
      notifyListeners();
    }
  }

  Future<void> updatePlayerColor(int index, Color color) async {
    if (index >= 0 && index < _players.length) {
      final player = _players[index];
      player.color = color;

      // Log the action
      final entry = HistoryEntry(
        timestamp: DateTime.now(),
        actionType: ActionType.playerUpdated,
        playerName: player.name,
        playerColor: color,
        additionalInfo: ": Color changed",
      );
      await _addHistoryEntry(entry);

      _saveCurrentGame();
      notifyListeners();
    }
  }

  Future<void> updatePlayerScore(int playerIndex, int score) async {
    if (_currentGameMode == null ||
        playerIndex < 0 ||
        playerIndex >= _players.length) {
      return;
    }

    final player = _players[playerIndex];
    final oldScore = player.score;
    player.addScore(score);
    final newScore = player.score;

    // Log the action
    final entry = HistoryEntry(
      timestamp: DateTime.now(),
      actionType: ActionType.scoreChanged,
      playerName: player.name,
      playerColor: player.color,
      scoreChange: score,
      oldScore: oldScore,
      newScore: newScore,
    );
    await _addHistoryEntry(entry);

    _saveCurrentGame();
    notifyListeners();
  }

  Future<void> deletePlayer(int playerIndex) async {
    if (playerIndex >= 0 && playerIndex < _players.length) {
      final player = _players[playerIndex];

      // Log the action
      final entry = HistoryEntry(
        timestamp: DateTime.now(),
        actionType: ActionType.playerRemoved,
        playerName: player.name,
        playerColor: player.color,
      );
      await _addHistoryEntry(entry);

      _players.removeAt(playerIndex);
      _saveCurrentGame();
      notifyListeners();
    }
  }

  // Save game state
  Future<String?> saveCurrentGame() async {
    // Make sure we're just calling the private method
    await _saveCurrentGame();

    String? savedGameId;

    // Save a snapshot of the current game
    if (_players.isNotEmpty && _currentGameMode != null) {
      savedGameId = await _storageService.saveGameSnapshot(
        _currentGameMode!,
        _players,
      );

      // Create a history entry for saved game
      final entry = HistoryEntry(
        timestamp: DateTime.now(),
        actionType: ActionType.gameSaved,
        playerName: "System", // Placeholder since required
        playerColor: Colors.grey, // Placeholder since required
        additionalInfo: " with ${_players.length} players",
      );
      await _addHistoryEntry(entry);

      // Refresh saved games list
      _savedGames = await _storageService.getSavedGames();
    }

    // Add haptic feedback when saving
    HapticFeedback.mediumImpact();

    notifyListeners();
    return savedGameId;
  }

  // Private save game method (unchanged)
  Future<void> _saveCurrentGame() async {
    if (_currentGameMode != null) {
      await _storageService.saveCurrentGame(_currentGameMode!, _players);
    } else {
      await _storageService.clearCurrentGame();
    }
  }

  // Clear current game
  Future<void> clearCurrentGame() async {
    _currentGameMode = null;
    _players = [];
    await _storageService.clearCurrentGame();
    notifyListeners();
  }

  // History management
  Future<void> _addHistoryEntry(HistoryEntry entry) async {
    _history.add(entry);

    final Map<String, dynamic> data = {
      'players': [
        for (var player in _players)
          {'name': player.name, 'score': player.score, 'color': ColorUtils.intToHex(player.color.value)},
      ],
      'gameMode': _currentGameMode?.title["en"] ?? "Score Counter",
      'channelId': 'score_counter_channel', // Pass channel ID in data
    };

    // Use unique ID based on timestamp for each notification
    final String notificationId = '${entry.timestamp.millisecondsSinceEpoch}';
    
    try {
      await _liveActivities.createActivity(
        notificationId,
        data,
      );
    } catch (e) {
      print("Error creating live activity: $e");
    }

    await _storageService.addHistoryEntry(entry);

    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _storageService.clearHistory();
    notifyListeners();
  }

  // Undo functionality
  Future<bool> undoLastAction() async {
    if (_history.isEmpty) {
      return false;
    }

    // Get the most recent action
    final lastEntry = _history.last;

    // Remove the entry from history
    _history.removeLast();
    await _storageService.saveHistoryEntries(_history);

    switch (lastEntry.actionType) {
      case ActionType.scoreChanged:
        // Find the player and revert their score
        final playerIndex = _players.indexWhere(
          (p) =>
              p.name == lastEntry.playerName &&
              p.color == lastEntry.playerColor,
        );

        if (playerIndex != -1 && lastEntry.oldScore != null) {
          _players[playerIndex].score = lastEntry.oldScore!;
        }
        break;

      case ActionType.playerAdded:
        // Remove the recently added player
        _players.removeWhere(
          (p) =>
              p.name == lastEntry.playerName &&
              p.color == lastEntry.playerColor,
        );
        break;

      case ActionType.playerRemoved:
        // We can't reliably restore a removed player without storing more information
        // This would require enhancing the history system to store complete player state
        return false;

      case ActionType.playerUpdated:
        // Handling player updates would require more detailed history
        // For now, we can't reliably undo these without additional data
        return false;

      case ActionType.gameSaved:
        // Nothing to undo for game saves
        return true;
    }

    await _saveCurrentGame();
    notifyListeners();
    return true;
  }

  // Screen wake lock functionality
  Future<void> setKeepScreenAwake(bool value) async {
    _keepScreenAwake = value;

    // Apply the setting
    if (value) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }

    // Save the setting
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_screen_awake', value);

    notifyListeners();
  }

  // Saved games functionality
  Future<void> loadSavedGames() async {
    _savedGames = await _storageService.getSavedGames();
    notifyListeners();
  }

  Future<void> deleteSavedGame(String id) async {
    await _storageService.deleteSavedGame(id);
    _savedGames = await _storageService.getSavedGames();
    notifyListeners();
  }

  Future<void> loadSavedGame(String id) async {
    final savedGame = await _storageService.getSavedGameById(id);
    if (savedGame != null) {
      _currentGameMode = savedGame.gameMode;
      _players = List<Player>.from(savedGame.players);
      await _saveCurrentGame();

      // Create a history entry
      final entry = HistoryEntry(
        timestamp: DateTime.now(),
        actionType: ActionType.gameSaved, // Reusing this action type
        playerName: "System",
        playerColor: Colors.grey,
        additionalInfo:
            " loaded saved game from ${_formatDate(savedGame.timestamp)}",
      );
      await _addHistoryEntry(entry);

      notifyListeners();
    }
  }

  // Reset all player scores to 0
  Future<void> resetScores() async {
    if (_players.isEmpty) return;

    // Reset scores for all players
    for (var player in _players) {
      player.score = 0;
    }

    // Create a history entry
    final entry = HistoryEntry(
      timestamp: DateTime.now(),
      actionType: ActionType.scoreChanged,
      playerName: "All players",
      playerColor: Colors.grey,
      scoreChange: 0,
      oldScore: null,
      newScore: 0,
      additionalInfo: " scores reset to 0",
    );
    await _addHistoryEntry(entry);

    await _saveCurrentGame();
    notifyListeners();
  }

  // Start a new game with current game mode but empty players
  Future<void> startNewGame() async {
    if (_currentGameMode == null) return;

    // Save current game before clearing
    if (_players.isNotEmpty) {
      await _storageService.saveGameSnapshot(_currentGameMode!, _players);
    }

    // Clear players list but keep the game mode
    _players = [];

    // Create a history entry
    final entry = HistoryEntry(
      timestamp: DateTime.now(),
      actionType: ActionType.gameSaved,
      playerName: "System",
      playerColor: Colors.grey,
      additionalInfo:
          " started new game with game mode: ${_currentGameMode!.title["en"]}",
    );
    await _addHistoryEntry(entry);

    await _saveCurrentGame();
    notifyListeners();
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'yesterday ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
