import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_mode.dart';
import '../providers/game_provider.dart';

class CreateGameModeDialog extends StatefulWidget {
  const CreateGameModeDialog({super.key});

  @override
  State<CreateGameModeDialog> createState() => _CreateGameModeDialogState();
}

class _CreateGameModeDialogState extends State<CreateGameModeDialog> {
  final TextEditingController _titleEnController = TextEditingController();
  final TextEditingController _titleViController = TextEditingController();
  final List<CountableObjectInput> _countableObjects = [
    CountableObjectInput(ballNumber: '', score: 1),
  ];
  bool _isFavorite = false;

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleViController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Game Mode'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleEnController,
              decoration: const InputDecoration(
                labelText: 'English Title',
                hintText: 'e.g., 9 ball 3, 6, 9',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleViController,
              decoration: const InputDecoration(
                labelText: 'Vietnamese Title',
                hintText: 'e.g., 9 bi 3, 6, 9',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Countable Objects:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._buildCountableObjectInputs(),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addCountableObject,
              icon: const Icon(Icons.add),
              label: const Text('Add Ball'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Add to Favorites'),
              value: _isFavorite,
              onChanged: (value) {
                setState(() {
                  _isFavorite = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _createGameMode,
          child: const Text('CREATE'),
        ),
      ],
    );
  }

  List<Widget> _buildCountableObjectInputs() {
    return _countableObjects.asMap().entries.map((entry) {
      final index = entry.key;
      final countableObject = entry.value;

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: countableObject.ballNumberController,
                decoration: const InputDecoration(
                  labelText: 'Ball Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: countableObject.scoreController,
                decoration: const InputDecoration(
                  labelText: 'Score',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            if (_countableObjects.length > 1)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[500]!),
                onPressed: () => _removeCountableObject(index),
              ),
          ],
        ),
      );
    }).toList();
  }

  void _addCountableObject() {
    setState(() {
      _countableObjects.add(CountableObjectInput(ballNumber: '', score: 1));
    });
  }

  void _removeCountableObject(int index) {
    setState(() {
      _countableObjects.removeAt(index);
    });
  }

  void _createGameMode() {
    final titleEn = _titleEnController.text.trim();
    final titleVi = _titleViController.text.trim();

    if (titleEn.isEmpty || titleVi.isEmpty) {
      _showErrorDialog('Please enter both English and Vietnamese titles.');
      return;
    }

    final countableObjects = <CountableObject>[];
    for (var input in _countableObjects) {
      final ballNumber = input.ballNumberController.text.trim();
      final scoreText = input.scoreController.text.trim();

      if (ballNumber.isEmpty) {
        _showErrorDialog('Please enter a ball number for each countable object.');
        return;
      }

      final score = int.tryParse(scoreText);
      if (score == null) {
        _showErrorDialog('Please enter a valid score for each countable object.');
        return;
      }

      countableObjects.add(CountableObject(
        ballNumber: ballNumber,
        score: score,
      ));
    }

    final gameMode = GameMode(
      title: {'en': titleEn, 'vi': titleVi},
      countableObjects: countableObjects,
      favourite: _isFavorite,
    );

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.addGameMode(gameMode);
    Navigator.pop(context);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class CountableObjectInput {
  final TextEditingController ballNumberController;
  final TextEditingController scoreController;

  CountableObjectInput({
    required String ballNumber,
    required int score,
  }) : ballNumberController = TextEditingController(text: ballNumber),
       scoreController = TextEditingController(text: score.toString());
}