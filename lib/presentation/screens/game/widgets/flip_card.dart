import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../data/models/card_model.dart';
import '../../../../core/constants/app_colors.dart';

class FlipCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const FlipCard({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // We animate the flip card using an AnimatedSwitcher or TweenAnimationBuilder.
    // TweenAnimationBuilder gives us a very precise 3D Y-axis rotation!
    final double targetRotation = (card.isFlipped || card.isMatched) ? pi : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: targetRotation),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, rotationAngle, child) {
          final isBackFacing = rotationAngle < pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Perspective depth parameter
              ..rotateY(rotationAngle),
            alignment: Alignment.center,
            child: isBackFacing
                ? _buildCardBack()
                : Transform(
                    // Rotate the front side back by pi so text is NOT mirrored!
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardFront(),
                  ),
          );
        },
      ),
    );
  }

  // Back of the card (hidden state - dark tech obsidian pattern with neon glowing borders)
  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: const Icon(
            Icons.question_mark_rounded,
            color: AppColors.secondary,
            size: 28,
          ),
        ),
      ),
    );
  }

  // Front of the card (revealed state - bright indigo or emerald green if matched)
  Widget _buildCardFront() {
    final Color borderColor = card.isMatched ? AppColors.success : AppColors.secondary;
    final Color bgColor = card.isMatched 
        ? AppColors.success.withValues(alpha: 0.15) 
        : AppColors.primary.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            card.content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: card.content.length > 25 ? 11 : (card.content.length > 12 ? 13 : 15),
            ),
          ),
        ),
      ),
    );
  }
}
