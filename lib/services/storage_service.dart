import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../models/history_entry.dart';
import '../models/saved_game.dart';

class StorageService {
  static const String _gameModeKey = 'game_modes';
  static const String _currentGameKey = 'current_game';
  static const String _historyKey = 'history_entries';
  static const String _savedGamesKey = 'saved_games';

  Future<void> saveGameModes(List<GameMode> gameModes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = gameModes.map((mode) => jsonEncode(mode.toJson())).toList();
    await prefs.setStringList(_gameModeKey, jsonList);
  }

  Future<List<GameMode>> getGameModes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_gameModeKey);

    if (jsonList == null || jsonList.isEmpty) {
      final defaultModes = getDefaultGameModes();
      await saveGameModes(defaultModes);
      return defaultModes;
    }

    return jsonList
        .map((jsonString) => 
            GameMode.fromJson(jsonDecode(jsonString) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCurrentGame(GameMode gameMode, List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final gameData = {
      'game_mode': gameMode.toJson(),
      'players': players.map((player) => player.toJson()).toList(),
    };
    await prefs.setString(_currentGameKey, jsonEncode(gameData));
  }

  Future<Map<String, dynamic>?> getCurrentGame() async {
    final prefs = await SharedPreferences.getInstance();
    final gameDataStr = prefs.getString(_currentGameKey);

    if (gameDataStr == null) {
      return null;
    }

    final gameData = jsonDecode(gameDataStr) as Map<String, dynamic>;
    final gameMode = GameMode.fromJson(gameData['game_mode']);
    final playersList = (gameData['players'] as List)
        .map((playerJson) => Player.fromJson(playerJson))
        .toList();

    return {
      'game_mode': gameMode,
      'players': playersList,
    };
  }

  Future<void> clearCurrentGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentGameKey);
  }
  
  // History entries methods
  Future<void> addHistoryEntry(HistoryEntry entry) async {
    final entries = await getHistoryEntries();
    entries.add(entry);
    
    // Limit history to the most recent 100 entries
    if (entries.length > 100) {
      entries.removeRange(0, entries.length - 100);
    }
    
    await _saveHistoryEntries(entries);
  }
  
  Future<List<HistoryEntry>> getHistoryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    return jsonList
        .map((jsonString) => 
            HistoryEntry.fromJson(jsonDecode(jsonString) as Map<String, dynamic>))
        .toList();
  }
  
  Future<void> _saveHistoryEntries(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }
  
  // Public method to save history entries for undo functionality
  Future<void> saveHistoryEntries(List<HistoryEntry> entries) async {
    await _saveHistoryEntries(entries);
  }
  
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
  
  // Saved games methods
  Future<String> saveGameSnapshot(GameMode gameMode, List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Create a unique ID for this saved game
    final id = const Uuid().v4();
    
    // Create saved game object
    final savedGame = SavedGame(
      id: id,
      timestamp: DateTime.now(),
      gameMode: gameMode,
      players: List<Player>.from(players),
    );
    
    // Get existing saved games
    final savedGames = await getSavedGames();
    
    // Add the new saved game
    savedGames.add(savedGame);
    
    // Save the updated list
    await _saveSavedGames(savedGames);
    
    return id;
  }
  
  Future<List<SavedGame>> getSavedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_savedGamesKey);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    return jsonList
        .map((jsonString) => 
            SavedGame.fromJson(jsonDecode(jsonString) as Map<String, dynamic>))
        .toList();
  }
  
  Future<void> _saveSavedGames(List<SavedGame> games) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = games.map((game) => jsonEncode(game.toJson())).toList();
    await prefs.setStringList(_savedGamesKey, jsonList);
  }
  
  Future<void> deleteSavedGame(String id) async {
    final games = await getSavedGames();
    games.removeWhere((game) => game.id == id);
    await _saveSavedGames(games);
  }
  
  Future<SavedGame?> getSavedGameById(String id) async {
    final games = await getSavedGames();
    try {
      return games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }
} 