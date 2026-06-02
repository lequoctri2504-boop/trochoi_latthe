import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/score_model.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/settings_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final game = Provider.of<GameProvider>(context);
    final firebaseService = FirebaseService();

    return DefaultTabController(
      length: 2,
      initialIndex: settings.isOfflineMode ? 1 : 0,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "BẢNG XẾP HẠNG",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.secondary,
            labelColor: AppColors.secondary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(
                icon: Icon(Icons.cloud_queue_rounded),
                text: "TRỰC TUYẾN (FIREBASE)",
              ),
              Tab(
                icon: Icon(Icons.phonelink_ring_rounded),
                text: "NGOẠI TUYẾN (MÁY)",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Cloud Leaderboard (Firebase)
            _buildCloudLeaderboard(firebaseService),
            
            // Tab 2: Local Leaderboard (SharedPreferences)
            _buildLocalLeaderboard(game),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudLeaderboard(FirebaseService firebaseService) {
    if (!firebaseService.isAvailable) {
      return _buildDisabledState(
        icon: Icons.cloud_off_rounded,
        title: "FIREBASE CHƯA ĐƯỢC KẾT NỐI",
        subtitle: "Vui lòng cấu hình file google-services.json hoặc tắt chế độ Ngoại tuyến trong phần Cài đặt để kích hoạt tính năng này.",
      );
    }

    return StreamBuilder<List<ScoreModel>>(
      stream: firebaseService.getGlobalLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
        }

        final scores = snapshot.data ?? [];
        if (scores.isEmpty) {
          return _buildEmptyState();
        }

        return _buildScoreList(scores);
      },
    );
  }

  Widget _buildLocalLeaderboard(GameProvider game) {
    final scores = game.localLeaderboard;
    if (scores.isEmpty) {
      return _buildEmptyState();
    }
    return _buildScoreList(scores);
  }

  Widget _buildScoreList(List<ScoreModel> scores) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        final rank = index + 1;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: rank <= 3 ? AppColors.secondary.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.02),
              width: rank <= 3 ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Rank indicator (Trophy or number)
              _buildRankBadge(rank),
              const SizedBox(width: 16),
              
              // Username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      score.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Thời gian: ${score.timeInSeconds}s | Lượt lật: ${score.flipsCount}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Final Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${score.score}",
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    "Điểm",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return const CircleAvatar(
        backgroundColor: Colors.amber,
        radius: 16,
        child: Icon(Icons.emoji_events_rounded, color: AppColors.background, size: 18),
      );
    } else if (rank == 2) {
      return const CircleAvatar(
        backgroundColor: Color(0xFFC0C0C0), // Silver
        radius: 16,
        child: Icon(Icons.emoji_events_rounded, color: AppColors.background, size: 18),
      );
    } else if (rank == 3) {
      return const CircleAvatar(
        backgroundColor: Color(0xFFCD7F32), // Bronze
        radius: 16,
        child: Icon(Icons.emoji_events_rounded, color: AppColors.background, size: 18),
      );
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(
        "$rank",
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, color: AppColors.textSecondary.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 16),
          const Text(
            "CHƯA CÓ THÀNH TÍCH NÀO",
            style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          const Text(
            "Hãy chơi game và vượt qua thử thách để lọt top bảng vàng nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white12, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.orange.withValues(alpha: 0.6), size: 64),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
