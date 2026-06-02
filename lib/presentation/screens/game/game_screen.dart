import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/game_provider.dart';
import 'widgets/flip_card.dart';
import '../../widgets/custom_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Consumer<GameProvider>(
          builder: (context, game, child) {
            return Text(
              game.currentTopic.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            _showExitWarningDialog();
          },
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          // Listen to victory state and trigger popup ONCE
          if (game.isWin && !_dialogShown) {
            _dialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showVictoryDialog(context, game);
            });
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // Game status board
                  _buildStatusBoard(game),
                  const SizedBox(height: 24),

                  // Game Cards Grid
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 columns
                        childAspectRatio: 0.8, // Rectangular card ratio
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: game.cards.length,
                      itemBuilder: (context, index) {
                        final card = game.cards[index];
                        return FlipCard(
                          card: card,
                          onTap: () {
                            game.flipCard(index);
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Bottom Hint panel
                  _buildHintPanel(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Beautiful top status card (Timer & Flips counters)
  Widget _buildStatusBoard(GameProvider game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Flips indicator
          _buildStatusItem(
            icon: Icons.sync_alt_rounded,
            value: "${game.flipsCount}",
            label: "Số lượt lật",
            color: AppColors.secondary,
          ),
          
          // Divider
          Container(width: 1, height: 32, color: Colors.white12),

          // Timer indicator
          _buildStatusItem(
            icon: Icons.timer_outlined,
            value: _formatDuration(game.timeElapsed),
            label: "Thời gian",
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHintPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Mẹo: Hãy ghép Thuật ngữ bên trái với Định nghĩa bên phải!",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showVictoryDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
        timeElapsed: game.timeElapsed,
        flipsCount: game.flipsCount,
        score: game.finalScore,
      ),
    ).then((_) {
      _dialogShown = false; // Reset state
    });
  }

  void _showExitWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Thoát trận?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "Tiến trình chơi hiện tại sẽ bị mất. Bạn có chắc chắn muốn quay lại sảnh không?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("HỦY BỎ", style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("THOÁT", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
