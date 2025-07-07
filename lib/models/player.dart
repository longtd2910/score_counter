import 'package:flutter/material.dart';

List<Color> playerColors = [
  Colors.red[700]!,
  Colors.blue[700]!,
  Colors.green[700]!,
  Colors.yellow[700]!,
  Colors.purple[700]!,
  Colors.orange[700]!,
  Colors.pink[700]!,
  Colors.teal[700]!,
  Colors.indigo[700]!,
  Colors.lime[700]!,
  Colors.amber[700]!,
  Colors.cyan[700]!,
];

class Player {
  String name;
  int score;
  Color color;

  Player({required this.name, this.score = 0, this.color = Colors.white});

  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
    'color_r': (color.r * 255.0).round(),
    'color_g': (color.g * 255.0).round(),
    'color_b': (color.b * 255.0).round(),
    'color_a': (color.a * 255.0).round(),
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      score: json['score'],
      color: Color.fromARGB(
        json['color_a'],
        json['color_r'],
        json['color_g'],
        json['color_b'],
      ),
    );
  }

  void addScore(int points) {
    score += points;
  }
}
