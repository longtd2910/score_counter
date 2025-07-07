import 'package:flutter/material.dart';
import 'package:score_counter/models/game_mode.dart';
import 'package:score_counter/models/player.dart';

class SavedGame {
  final String id;
  final DateTime timestamp;
  final GameMode gameMode;
  final List<Player> players;

  SavedGame({
    required this.id,
    required this.timestamp,
    required this.gameMode,
    required this.players,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'gameMode': gameMode.toJson(),
      'players': players.map((player) => player.toJson()).toList(),
    };
  }

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    return SavedGame(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      gameMode: GameMode.fromJson(json['gameMode']),
      players: (json['players'] as List)
          .map((playerJson) => Player.fromJson(playerJson))
          .toList(),
    );
  }
} 