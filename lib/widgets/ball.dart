import 'package:flutter/material.dart';

class Ball extends StatelessWidget {
  final String number;
  final double rotationAngle; // Add rotation angle parameter

  const Ball({
    super.key, 
    required this.number, 
    this.rotationAngle = 0.0, // Default to no rotation
  });

  @override
  Widget build(BuildContext context) {
    Color stripeColor;
    Color ballColor;
    final ballNumber = int.tryParse(number);

    final List<Color> colors = [
      Colors.yellow[300]!,
      Colors.blue[300]!,
      Colors.red[300]!,
      Colors.pink[300]!,
      Colors.orange[300]!,
      Colors.green[300]!,
      Colors.brown[300]!,
      Colors.black,
    ];

    ballColor = colors[(ballNumber ?? 0) % colors.length - 1];
    stripeColor = ballNumber != null && ballNumber >= 9 && ballNumber <= 15
        ? Colors.black
        : ballColor;
    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        width: 32,
        height: 32,
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: stripeColor, shape: BoxShape.circle),
        foregroundDecoration: BoxDecoration(border: Border.all(width: 0.5), shape: BoxShape.circle),
        child: Container(
          height: 14,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(color: ballColor),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 0.5),
              shape: BoxShape.circle,
            ),
            child: Text(number, style: const TextStyle(color: Colors.black, fontSize: 8)),
          ),
        ),
      ),
    );
  }
}
