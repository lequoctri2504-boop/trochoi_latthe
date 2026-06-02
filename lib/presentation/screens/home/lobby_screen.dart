import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/game_provider.dart';
import '../game/game_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';
import '../../widgets/custom_button.dart';
import '../../../core/services/local_data_service.dart';
import '../../../core/services/firebase_service.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _customTopicController = TextEditingController();
  List<Map<String, dynamic>> _topics = [];
  bool _isLoadingTopics = true;

  @override
  void initState() {
    super.initState();
    // Load dynamic topics asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTopics();
    });
  }

  Future<void> _loadTopics() async {
    if (!mounted) return;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final firebaseService = FirebaseService();
    
    List<Map<String, dynamic>> loadedTopics = [];
    
    // Only attempt Firestore dynamic load if online mode is enabled and Firebase is available
    if (!settings.isOfflineMode && firebaseService.isAvailable) {
      try {
        final firestoreTopics = await firebaseService.getTopicsFromFirestore();
        if (firestoreTopics.isNotEmpty) {
          loadedTopics = firestoreTopics;
        }
      } catch (e) {
        // Safe fallback in catch block
      }
    }
    
    // Offline mode or failed to fetch -> fallback to local predefined topics
    if (loadedTopics.isEmpty) {
      loadedTopics = LocalDataService().getPredefinedTopics();
    }
    
    if (mounted) {
      setState(() {
        _topics = loadedTopics;
        _isLoadingTopics = false;
      });
    }
  }

  @override
  void dispose() {
    _customTopicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          child: game.isLoadingCards
              ? _buildLoadingState(game.currentTopic)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        _buildHeaderRow(context, auth, settings),
                        const SizedBox(height: 32),

                        // User Greeting card
                        _buildUserGreetingCard(auth, settings),
                        const SizedBox(height: 28),

                        // Section 1: Pre-defined Topics
                        const Text(
                          "CHỌN CHỦ ĐỀ CHƠI NHANH",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        _isLoadingTopics
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32.0),
                                  child: SpinKitFadingCircle(
                                    color: AppColors.secondary,
                                    size: 40.0,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: _topics.length,
                                itemBuilder: (context, index) {
                                  final topic = _topics[index];
                                  final title = topic['title'] as String;
                                  final description = topic['description'] as String;
                                  final icon = _getIconData(topic['icon'] as String);
                                  final color = _getColor(topic['color'] as String);
                                  
                                  return _buildTopicCard(
                                    title: title,
                                    description: description,
                                    icon: icon,
                                    color: color,
                                    onTap: () => _startGame(context, title, settings, isPredefined: true),
                                  );
                                },
                              ),
                        const SizedBox(height: 32),

                        // Section 2: AI Custom Topic
                        const Text(
                          "SÁNG TẠO CHỦ ĐỀ CỦA RIÊNG BẠN (AI SINH THẺ)",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _customTopicController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Ví dụ: Các loại hoa quả, Lịch sử Việt Nam...",
                                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.15)),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.secondary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: settings.isOfflineMode 
                                    ? "CHƠI CHỦ ĐỀ CỦA BẠN (LOCAL MOCK)" 
                                    : "Yêu cầu AI sinh thẻ",
                                icon: Icons.auto_awesome_rounded,
                                onPressed: () {
                                  final topic = _customTopicController.text.trim();
                                  if (topic.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Vui lòng nhập chủ đề trước khi bắt đầu!"),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }
                                  _startGame(context, topic, settings);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(String topic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitDoubleBounce(
            color: AppColors.secondary,
            size: 80.0,
          ),
          const SizedBox(height: 32),
          const Text(
            "ĐANG SINH BÀN CHƠI...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "AI đang chuẩn bị thẻ bài cho chủ đề:\n\"$topic\"",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "(Vui lòng chờ khoảng 1-5 giây...)",
            style: TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, AuthProvider auth, SettingsProvider settings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
            const Text(
              "Đăng xuất",
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        Row(
          children: [
            // Leaderboard button
            IconButton(
              icon: const Icon(Icons.leaderboard_rounded, color: Colors.amber, size: 28),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            // Settings button
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserGreetingCard(AuthProvider auth, SettingsProvider settings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CHÀO MỪNG BẠN,",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1.0),
                ),
                Text(
                  auth.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: settings.isOfflineMode ? Colors.orange : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      settings.isOfflineMode ? "Chế độ: Offline (Cục bộ)" : "Chế độ: Trực tuyến (Cloud/AI)",
                      style: TextStyle(
                        color: settings.isOfflineMode ? Colors.orange : AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'code_rounded':
        return Icons.code_rounded;
      case 'public_rounded':
        return Icons.public_rounded;
      case 'translate_rounded':
        return Icons.translate_rounded;
      case 'history_edu_rounded':
        return Icons.history_edu_rounded;
      case 'auto_awesome_rounded':
        return Icons.auto_awesome_rounded;
      case 'pets_rounded':
        return Icons.pets_rounded;
      case 'psychology_rounded':
        return Icons.psychology_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'primary':
        return AppColors.primary;
      case 'secondary':
        return AppColors.secondary;
      case 'accent':
        return AppColors.accent;
      case 'orange':
        return Colors.orangeAccent;
      case 'purple':
        return Colors.purpleAccent;
      case 'green':
        return AppColors.success;
      case 'pink':
        return Colors.pinkAccent;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildTopicCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cardWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: color.withValues(alpha: 0.15),
      highlightColor: color.withValues(alpha: 0.05),
      child: cardWidget,
    );
  }

  Future<void> _startGame(BuildContext context, String topic, SettingsProvider settings, {bool isPredefined = false}) async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    await gameProvider.startNewGame(
      topic: topic,
      apiKey: settings.aiProvider == "gemini" ? settings.geminiApiKey : settings.deepSeekApiKey,
      aiProvider: settings.aiProvider,
      isOffline: settings.isOfflineMode || isPredefined,
    );

    if (context.mounted) {
      if (gameProvider.deepSeekError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "KHÔNG THỂ KẾT NỐI ${settings.aiProvider.toUpperCase()} AI",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),
                      ),
                      Text(
                        "${gameProvider.deepSeekError}\n(Hệ thống tự động tải bộ thẻ bài mẫu ngoại tuyến)",
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFC0392B),
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            action: SnackBarAction(
              label: "ĐỒNG Ý",
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }

      if (gameProvider.isPlaying) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GameScreen()),
        );
      }
    }
  }
}
