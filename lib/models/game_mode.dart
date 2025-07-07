class CountableObject {
  final String ballNumber;
  final int score;

  CountableObject({
    required this.ballNumber,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'ball_number': ballNumber,
        'score': score,
      };

  factory CountableObject.fromJson(Map<String, dynamic> json) {
    return CountableObject(
      ballNumber: json['ball_number'] as String,
      score: json['score'] as int,
    );
  }
}

class GameMode {
  final Map<String, String> title;
  final List<CountableObject> countableObjects;
  bool favourite;

  GameMode({
    required this.title,
    required this.countableObjects,
    this.favourite = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'countable_objects': countableObjects
            .map((countableObject) => countableObject.toJson())
            .toList(),
        'favourite': favourite,
      };

  factory GameMode.fromJson(Map<String, dynamic> json) {
    final countableObjectsList = json['countable_objects'] as List;
    return GameMode(
      title: Map<String, String>.from(json['title']),
      countableObjects: countableObjectsList
          .map((item) => CountableObject.fromJson(item as Map<String, dynamic>))
          .toList(),
      favourite: json['favourite'] ?? false,
    );
  }

  String getLocalizedTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? 'Unknown';
  }
}

// Default game modes
List<GameMode> getDefaultGameModes() {
  return [
    GameMode(
      title: {'en': '9 ball 3, 6, 9', 'vi': '9 bi 3, 6, 9'},
      countableObjects: [
        CountableObject(ballNumber: '3', score: 1),
        CountableObject(ballNumber: '6', score: 2),
        CountableObject(ballNumber: '9', score: 3),
      ],
      favourite: true,
    ),
    GameMode(
      title: {'en': '9 ball 5, 9', 'vi': '9 bi 5, 9'},
      countableObjects: [
        CountableObject(ballNumber: '5', score: 1),
        CountableObject(ballNumber: '9', score: 2),
      ],
      favourite: false,
    ),
    GameMode(
      title: {'en': '10 ball 5, 10', 'vi': '10 bi 5, 10'},
      countableObjects: [
        CountableObject(ballNumber: '5', score: 1),
        CountableObject(ballNumber: '10', score: 2),
      ],
      favourite: true,
    ),
  ];
} 