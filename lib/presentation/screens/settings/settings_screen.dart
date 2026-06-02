import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _geminiKeyController = TextEditingController();
  bool _obscureGeminiKey = true;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _geminiKeyController.text = settings.geminiApiKey;
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "CÀI ĐẶT HỆ THỐNG",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Connection Mode
                _buildSectionHeader("CHẾ ĐỘ KẾT NỐI CƠ SỞ DỮ LIỆU"),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      "Chế độ Ngoại tuyến (Offline)",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "Ngắt kết nối với Firebase. Điểm số sẽ lưu cục bộ trên máy và dùng dữ liệu thẻ bài mẫu ngoại tuyến.",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    activeThumbColor: AppColors.secondary,
                    value: settings.isOfflineMode,
                    onChanged: (val) {
                      settings.setOfflineMode(val);
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Section 2: AI Engine Config
                _buildSectionHeader("CẤU HÌNH API KEY TRÍ TUỆ NHÂN TẠO (GOOGLE GEMINI)"),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Google Gemini Key Input
                      const Text(
                        "Google Gemini API Key",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Tạo khóa miễn phí 100% tại Google AI Studio (aistudio.google.com). Key của bạn sẽ được lưu bảo mật trên thiết bị.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _geminiKeyController,
                        obscureText: _obscureGeminiKey,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Nhập khóa AIzaSy...",
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                          filled: true,
                          fillColor: AppColors.background,
                          prefixIcon: const Icon(Icons.auto_awesome_outlined, color: AppColors.secondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureGeminiKey ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureGeminiKey = !_obscureGeminiKey;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.secondary),
                          ),
                        ),
                        onChanged: (val) {
                          settings.setGeminiApiKey(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Section 4: Student Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E1C5C), Color(0xFF130833)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.school_rounded, color: AppColors.secondary, size: 36),
                      SizedBox(height: 12),
                      Text(
                        "ĐỒ ÁN MÔN HỌC FLUTTER- XÂY DỰNG ỨNG DỤNG DI ĐỘNG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Sinh viên thực hiện: LÊ QUỐC TRÍ",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Mã số SV: DH52201621_D22_TH14",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }
}
