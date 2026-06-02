import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import 'custom_button.dart';

class CustomDialog extends StatefulWidget {
  final int timeElapsed;
  final int flipsCount;
  final int score;

  const CustomDialog({
    super.key,
    required this.timeElapsed,
    required this.flipsCount,
    required this.score,
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate username if logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _nameController.text = auth.displayName;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Trophy Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Victory Title
            const Text(
              "CHIẾN THẮNG!",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Bạn đã ghép thành công các thẻ bài!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Performance Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    icon: Icons.timer_outlined,
                    label: "Thời gian",
                    value: "${widget.timeElapsed}s",
                    color: AppColors.secondary,
                  ),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
                  _buildStatColumn(
                    icon: Icons.sync_alt_rounded,
                    label: "Lượt lật",
                    value: "${widget.flipsCount}",
                    color: AppColors.accent,
                  ),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
                  _buildStatColumn(
                    icon: Icons.star_border_rounded,
                    label: "Điểm số",
                    value: "${widget.score}",
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Input Nickname Field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Tên hiển thị để lưu điểm",
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            CustomButton(
              text: "LƯU ĐIỂM & HOÀN THÀNH",
              isLoading: _isSaving,
              onPressed: () async {
                if (_hasPopped) return;
                
                setState(() {
                  _isSaving = true;
                });
                
                final String username = _nameController.text.trim().isNotEmpty
                    ? _nameController.text.trim()
                    : "Người chơi ẩn danh";
                
                // Set name locally in auth provider
                authProvider.setLocalNickname(username);
                
                // Capture navigator and scaffoldMessenger before async gap
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                // Save score
                await gameProvider.saveFinalScore(
                  username,
                  settingsProvider.isOfflineMode,
                );

                if (mounted) {
                  setState(() {
                    _isSaving = false;
                  });
                }

                if (_hasPopped) return;
                _hasPopped = true;

                // Show premium green success snackbar
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          "Đã lưu điểm số thành công!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Explicit double pop with safe canPop() checks
                if (navigator.canPop()) {
                  navigator.pop(); // Close dialog
                  if (navigator.canPop()) {
                    navigator.pop(); // Close GameScreen and return to Lobby
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
