import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Gắn thẳng API Key của bạn tại đây để ứng dụng tự động chạy AI mà không cần nhập trên điện thoại
  static const String defaultDeepSeekKey = "sk-6f2a79a22dfa4d1ab806f446d5b349ae";
  static const String defaultGeminiKey = "AIzaSyCBd8SsDVMtA9NAHc6qv4DleKsdwQbmMVw";

  String _deepSeekApiKey = defaultDeepSeekKey == "NHAP_DEEPSEEK_API_KEY_CUA_BAN_TAI_DAY" ? "" : defaultDeepSeekKey;
  String _geminiApiKey = defaultGeminiKey == "NHAP_GEMINI_API_KEY_CUA_BAN_TAI_DAY" ? "" : defaultGeminiKey;
  
  String _aiProvider = "gemini"; // Mặc định dùng Gemini để được MIỄN PHÍ 100%
  bool _isOfflineMode = false; // Mặc định thành false (Online) để kết nối ngay

  String get deepSeekApiKey => _deepSeekApiKey;
  String get geminiApiKey => _geminiApiKey;
  String get aiProvider => "gemini";
  bool get isOfflineMode => _isOfflineMode;

  SettingsProvider() {
    loadSettings();
  }

  // Load saved configurations from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _deepSeekApiKey = prefs.getString('deepseek_api_key') ?? "";
    if (_deepSeekApiKey.isEmpty && defaultDeepSeekKey != "NHAP_DEEPSEEK_API_KEY_CUA_BAN_TAI_DAY") {
      _deepSeekApiKey = defaultDeepSeekKey;
    }
    
    _geminiApiKey = prefs.getString('gemini_api_key') ?? "";
    if (_geminiApiKey.isEmpty && defaultGeminiKey != "NHAP_GEMINI_API_KEY_CUA_BAN_TAI_DAY") {
      _geminiApiKey = defaultGeminiKey;
    }
    
    _aiProvider = "gemini";
    _isOfflineMode = prefs.getBool('is_offline_mode') ?? false;
    notifyListeners();
  }

  // Save and update DeepSeek API key
  Future<void> setDeepSeekApiKey(String key) async {
    _deepSeekApiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deepseek_api_key', _deepSeekApiKey);
    notifyListeners();
  }

  // Save and update Gemini API key
  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _geminiApiKey);
    notifyListeners();
  }

  // Change AI Provider
  Future<void> setAiProvider(String provider) async {
    _aiProvider = provider;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_provider', _aiProvider);
    notifyListeners();
  }

  // Change Offline/Online mode
  Future<void> setOfflineMode(bool isOffline) async {
    _isOfflineMode = isOffline;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_offline_mode', _isOfflineMode);
    notifyListeners();
  }
}
