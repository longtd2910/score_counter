import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:score_counter/models/game_mode.dart';
import 'package:score_counter/widgets/ball.dart';

class ActionBar extends StatefulWidget {
  final GameMode gameMode;
  final Function(int) changeScoreCallback;

  const ActionBar({
    super.key,
    required this.gameMode,
    required this.changeScoreCallback,
  });

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> with SingleTickerProviderStateMixin {
  final Map<int, double> _ballRotations = {};
  final Map<int, double> _ballOffsets = {};
  final Map<int, double> _dragStartX = {};
  final double _maxDragDistance = 120.0; // Increased to allow reaching arrows
  
  late AnimationController _animationController;
  int? _currentDragIndex;
  bool _isAnimatingBack = false;
  
  // Track if we're currently dragging
  bool get isDragging => _currentDragIndex != null;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animationController.addListener(() {
      if (_isAnimatingBack && mounted) {
        final dragIndex = _currentDragIndex!;
        setState(() {
          // Create spring-back animation
          final progress = Curves.elasticOut.transform(_animationController.value);
          final startOffset = _ballOffsets[dragIndex] ?? 0.0;
          _ballOffsets[dragIndex] = startOffset * (1 - progress);
          _ballRotations[dragIndex] = -_ballOffsets[dragIndex]! * 0.15;
        });
      }
    });
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimatingBack = false;
          _currentDragIndex = null; // Clear drag index when animation is done
        });
      }
    });
    
    // Initialize offsets and rotations
    for (int i = 0; i < widget.gameMode.countableObjects.length; i++) {
      _ballOffsets[i] = 0.0;
      _ballRotations[i] = 0.0;
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Calculate offset for non-dragged balls (to move them aside)
  double _calculateNonDraggedOffset(int index) {
    if (!isDragging || _isAnimatingBack || _currentDragIndex == index) return 0.0;
    
    // Calculate offset based on the current dragged ball's position
    final draggedOffset = _ballOffsets[_currentDragIndex!] ?? 0.0;
    
    // If dragged ball is to the left of this ball, move this ball right
    // If dragged ball is to the right of this ball, move this ball left
    if (_currentDragIndex! < index) {
      // Move right if dragged ball is moving right
      return max(0, draggedOffset * 0.5);
    } else {
      // Move left if dragged ball is moving left
      return min(0, draggedOffset * 0.5);
    }
  }
  
  // Calculate opacity for balls based on drag state
  double _calculateBallOpacity(int index) {
    if (!isDragging || _isAnimatingBack) return 1.0; // Full opacity when not dragging or when animating back
    if (_currentDragIndex == index) return 1.0; // Full opacity for dragged ball
    
    // Dim other balls to 0.3 opacity
    return 0.3;
  }
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> actionBalls = [];

    for (int i = 0; i < widget.gameMode.countableObjects.length; i++) {
      final ballIndex = i;
      
      // Calculate if ball can trigger scoring on arrows
      final ballOffset = _ballOffsets[ballIndex] ?? 0.0;
      final canTriggerLeftArrow = ballOffset <= -_maxDragDistance * 0.9;
      final canTriggerRightArrow = ballOffset >= _maxDragDistance * 0.9;

      actionBalls.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
          width: 40, // Fixed container width for proper alignment
          alignment: Alignment.center,
          // Apply offset for non-dragged balls (moving them aside)
          transform: Matrix4.translationValues(_calculateNonDraggedOffset(ballIndex), 0, 0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuad,
            opacity: _calculateBallOpacity(ballIndex),
            child: Transform.translate(
              offset: Offset(_ballOffsets[ballIndex] ?? 0.0, 0),
              child: GestureDetector(
                onHorizontalDragStart: (details) {
                  _dragStartX[ballIndex] = details.localPosition.dx;
                  setState(() {
                    _currentDragIndex = ballIndex;
                    _isAnimatingBack = false;
                  });
                  _animationController.reset();
                },
                onHorizontalDragUpdate: (details) {
                  // Calculate drag distance
                  final currentX = details.localPosition.dx;
                  final dragDelta = currentX - (_dragStartX[ballIndex] ?? 0);
                  
                  // Limit the drag distance
                  final limitedDragDelta = dragDelta.clamp(-_maxDragDistance, _maxDragDistance);
                  
                  setState(() {
                    // Update ball position offset
                    _ballOffsets[ballIndex] = limitedDragDelta;
                    
                    // Calculate rotation based on movement (negative to roll in correct direction)
                    _ballRotations[ballIndex] = -limitedDragDelta * 0.15;
                    
                    // Check if we're touching arrows and trigger effect if needed
                    if (canTriggerLeftArrow || canTriggerRightArrow) {
                      HapticFeedback.lightImpact();
                    }
                  });
                },
                onHorizontalDragEnd: (details) {
                  // Get final offset
                  final offset = _ballOffsets[ballIndex] ?? 0.0;
                  
                  // Check if we should trigger score change
                  // Either based on offset threshold or reaching arrows
                  if (offset.abs() > 20 || canTriggerLeftArrow || canTriggerRightArrow) {
                    final direction = offset > 0 ? 1 : -1;
                    final score = widget.gameMode.countableObjects[ballIndex].score * direction;
                    widget.changeScoreCallback(score);
                    HapticFeedback.mediumImpact();
                  }
                  
                  // Mark that we're now animating back
                  setState(() {
                    _isAnimatingBack = true;
                  });
                  
                  // Start animation to bring ball back to center
                  _animationController.forward(from: 0.0);
                },
                child: Ball(
                  number: widget.gameMode.countableObjects[ballIndex].ballNumber.toString(),
                  rotationAngle: _ballRotations[ballIndex] ?? 0.0,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDragging && !_isAnimatingBack ? 0.8 : 0.5,
            child: Icon(
              Icons.keyboard_double_arrow_left_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          ...actionBalls,
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDragging && !_isAnimatingBack ? 0.8 : 0.5,
            child: Icon(
              Icons.keyboard_double_arrow_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
