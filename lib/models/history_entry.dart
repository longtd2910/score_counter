import 'package:flutter/material.dart';
import 'player.dart';

enum ActionType {
  playerAdded,
  playerUpdated,
  playerRemoved,
  scoreChanged,
  gameSaved,
}

class HistoryEntry {
  final DateTime timestamp;
  final ActionType actionType;
  final String playerName;
  final Color playerColor;
  final int? scoreChange;
  final String? additionalInfo;
  final int? oldScore;
  final int? newScore;

  HistoryEntry({
    required this.timestamp,
    required this.actionType,
    required this.playerName,
    required this.playerColor,
    this.scoreChange,
    this.additionalInfo,
    this.oldScore,
    this.newScore,
  });

  String get actionDescription {
    switch (actionType) {
      case ActionType.playerAdded:
        return 'Player added';
      case ActionType.playerUpdated:
        return 'Player updated$additionalInfo';
      case ActionType.playerRemoved:
        return 'Player removed';
      case ActionType.scoreChanged:
        final points = scoreChange!.abs() == 1 ? 'point' : 'points';
        return scoreChange! > 0
            ? '+$scoreChange $points'
            : '$scoreChange $points';
      case ActionType.gameSaved:
        return 'Game saved$additionalInfo';
    }
  }

  String get scoreChangeDisplay {
    if (actionType != ActionType.scoreChanged || oldScore == null || newScore == null) {
      return '';
    }
    return '[$oldScore → $newScore]';
  }

  String get scoreChangeSymbol {
    if (actionType != ActionType.scoreChanged || scoreChange == null) {
      return '';
    }
    return scoreChange! > 0 ? '+' : '−';
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'actionType': actionType.index,
      'playerName': playerName,
      'playerColor': playerColor.value,
      'scoreChange': scoreChange,
      'additionalInfo': additionalInfo,
      'oldScore': oldScore,
      'newScore': newScore,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      timestamp: DateTime.parse(json['timestamp']),
      actionType: ActionType.values[json['actionType']],
      playerName: json['playerName'],
      playerColor: Color(json['playerColor']),
      scoreChange: json['scoreChange'],
      additionalInfo: json['additionalInfo'],
      oldScore: json['oldScore'],
      newScore: json['newScore'],
    );
  }
} 