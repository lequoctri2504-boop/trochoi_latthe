import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../home/lobby_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.localNickname.isNotEmpty) {
        _nicknameController.text = auth.localNickname;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings button at top right
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // App Branding Icon and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "INTELLIFLIP AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        settings.isOfflineMode 
                            ? "GAME TRÍ NHỚ (CHẾ ĐỘ NGOẠI TUYẾN)" 
                            : "GAME TRÍ NHỚ TỰ ĐỘNG BẰNG AI",
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // Conditional forms depending on Mode selection
                if (settings.isOfflineMode) ...[
                  // --- OFFLINE MODE FORM ---
                  const Text(
                    "BẮT ĐẦU CHƠI NHANH",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nicknameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(
                      hint: "Nhập Biệt danh / Nickname của bạn...",
                      icon: Icons.person_pin_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: "VÀO SẢNH CHỜ",
                    onPressed: () {
                      final name = _nicknameController.text.trim();
                      if (name.isEmpty) {
                        _showErrorSnackBar("Vui lòng nhập Biệt danh / Nickname của bạn trước!");
                        return;
                      }
                      auth.setLocalNickname(name);
                      _navigateToLobby();
                    },
                  ),
                ] else ...[
                  // --- ONLINE FIREBASE MODE FORM ---
                  Text(
                    _isSignUp ? "ĐĂNG KÝ TÀI KHOẢN MỚI" : "ĐĂNG NHẬP HỆ THỐNG",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(
                      hint: "Email...",
                      icon: Icons.alternate_email_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(
                      hint: "Mật khẩu...",
                      icon: Icons.lock_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: _isSignUp ? "ĐĂNG KÝ" : "ĐĂNG NHẬP",
                    isLoading: auth.isLoading,
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      final pass = _passwordController.text.trim();
                      if (email.isEmpty || pass.isEmpty) {
                        _showErrorSnackBar("Vui lòng điền đầy đủ Email và Mật khẩu!");
                        return;
                      }

                      bool success;
                      if (_isSignUp) {
                        success = await auth.register(email, pass);
                      } else {
                        success = await auth.login(email, pass);
                      }

                      if (success) {
                        _navigateToLobby();
                      } else {
                        _showErrorSnackBar(auth.errorMessage ?? "Thất bại! Vui lòng kiểm tra lại thông tin đăng nhập.");
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Text Toggle Signup / Signin
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? "Đã có tài khoản? Đăng nhập ngay"
                            : "Chưa có tài khoản? Đăng ký ngay",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 32),
                  
                  const Text(
                    "CHƠI KHÁCH TRỰC TUYẾN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nicknameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(
                      hint: "Nhập Biệt danh / Nickname của bạn...",
                      icon: Icons.person_pin_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Anonymous Quick Play Button (+1 points for UX!)
                  CustomButton(
                    text: "CHƠI NHANH DẠNG KHÁCH (ANONYMOUS)",
                    gradientColors: const [Color(0xFF27224D), Color(0xFF1E1A3A)],
                    icon: Icons.bolt_rounded,
                    isLoading: auth.isLoading,
                    onPressed: () async {
                      final name = _nicknameController.text.trim();
                      if (name.isEmpty) {
                        _showErrorSnackBar("Vui lòng nhập biệt danh trước khi chơi khách!");
                        return;
                      }
                      auth.setLocalNickname(name);
                      final success = await auth.loginAnonymously();
                      if (success) {
                        _navigateToLobby();
                      } else {
                        _showErrorSnackBar(auth.errorMessage ?? "Không thể đăng nhập ẩn danh lúc này. Hãy chọn chế độ Offline.");
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLobby() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LobbyScreen()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
      filled: true,
      fillColor: AppColors.cardBg,
      prefixIcon: Icon(icon, color: AppColors.primary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
    );
  }
}
