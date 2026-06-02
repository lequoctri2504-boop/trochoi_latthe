import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  User? _firebaseUser;
  String _localNickname = "";
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get localNickname => _localNickname;
  
  // Get active username depending on connection state
  String get displayName {
    if (_firebaseService.isAvailable && _firebaseUser != null) {
      if (_firebaseUser!.isAnonymous) {
        return _localNickname.trim().isNotEmpty
            ? _localNickname
            : "Khách (${_firebaseUser!.uid.substring(0, 5)})";
      }
      return _firebaseUser!.email ?? "Người dùng";
    }
    return _localNickname.isNotEmpty ? _localNickname : "Người chơi";
  }

  bool get isLoggedIn => (_firebaseService.isAvailable && _firebaseUser != null) || _localNickname.isNotEmpty;

  AuthProvider() {
    loadLocalNickname();
    // Listen to firebase auth changes if available
    if (_firebaseService.isAvailable) {
      _firebaseService.authStateChanges().listen((user) {
        _firebaseUser = user;
        notifyListeners();
      });
    }
  }

  // Load saved nickname from SharedPreferences
  Future<void> loadLocalNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('local_nickname') ?? "";
      if (savedName.isNotEmpty) {
        _localNickname = savedName;
        notifyListeners();
      }
    } catch (e) {
      developer.log("Error loading local nickname: $e");
    }
  }

  // Set nickname for Offline Mode
  Future<void> setLocalNickname(String name) async {
    if (name.trim().isNotEmpty) {
      _localNickname = name.trim();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_nickname', _localNickname);
      } catch (e) {
        developer.log("Error saving local nickname: $e");
      }
      notifyListeners();
    }
  }

  // Firebase Auth Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firebaseService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
      developer.log("Login failed: $e");
      return false;
    }
  }

  // Firebase Auth Signup
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firebaseService.signUpWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
      developer.log("Signup failed: $e");
      return false;
    }
  }

  // Firebase Auth Anonymous Login
  Future<bool> loginAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firebaseService.signInAnonymously();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
      developer.log("Anonymous login failed: $e");
      return false;
    }
  }

  String _cleanErrorMessage(String rawError) {
    final lower = rawError.toLowerCase();
    if (lower.contains("email-already-in-use")) {
      return "Email này đã được đăng ký bởi tài khoản khác!";
    } else if (lower.contains("invalid-email")) {
      return "Định dạng Email không hợp lệ!";
    } else if (lower.contains("weak-password")) {
      return "Mật khẩu quá yếu (tối thiểu phải 6 ký tự)!";
    } else if (lower.contains("user-not-found") || lower.contains("wrong-password") || lower.contains("invalid-credential")) {
      return "Email hoặc Mật khẩu không chính xác!";
    } else if (lower.contains("operation-not-allowed")) {
      return "Phương thức này chưa được bật trong Firebase Console (Authentication -> Sign-in method)!";
    } else if (lower.contains("network-request-failed")) {
      return "Lỗi mạng! Vui lòng kiểm tra lại Wifi/3G.";
    }
    return "Lỗi: ${rawError.replaceFirst(RegExp(r'\[.*?\]\s*'), '')}";
  }

  // Logout
  Future<void> logout() async {
    if (_firebaseService.isAvailable) {
      await _firebaseService.signOut();
      _firebaseUser = null;
    }
    _localNickname = "Người chơi";
    notifyListeners();
  }
}
