import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/card_model.dart';
import '../data/models/score_model.dart';
import '../core/services/deepseek_service.dart';
import '../core/services/gemini_service.dart';
import '../core/services/firebase_service.dart';
import '../core/services/local_data_service.dart';

class GameProvider with ChangeNotifier {
  final DeepSeekService _deepSeekService = DeepSeekService();
  final GeminiService _geminiService = GeminiService();
  final FirebaseService _firebaseService = FirebaseService();
  final LocalDataService _localDataService = LocalDataService();

  List<CardModel> _cards = [];
  bool _isPlaying = false;
  bool _isLoadingCards = false;
  bool _isWin = false;
  int _timeElapsed = 0;
  int _flipsCount = 0;
  String _currentTopic = "";
  
  Timer? _timer;
  int? _firstFlippedIndex;
  bool _isBusy = false; // Lock user input when 2 incorrect cards are showing

  List<CardModel> get cards => _cards;
  bool get isPlaying => _isPlaying;
  bool get isLoadingCards => _isLoadingCards;
  bool get isWin => _isWin;
  int get timeElapsed => _timeElapsed;
  int get flipsCount => _flipsCount;
  String get currentTopic => _currentTopic;

  // Local offline leaderboard cache
  List<ScoreModel> _localLeaderboard = [];
  List<ScoreModel> get localLeaderboard => _localLeaderboard;

  GameProvider() {
    loadLocalLeaderboard();
  }

  // Load offline scoreboard from SharedPreferences
  Future<void> loadLocalLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('local_leaderboard');
    if (rawData != null) {
      final List<dynamic> decoded = jsonDecode(rawData);
      _localLeaderboard = decoded.map((item) => ScoreModel.fromJson(item)).toList();
      _localLeaderboard.sort((a, b) => b.score.compareTo(a.score)); // Sort highest first
    }
    notifyListeners();
  }

  // Start the Flip Card Memory Game
  String? _deepSeekError;
  String? get deepSeekError => _deepSeekError;

  void clearDeepSeekError() {
    _deepSeekError = null;
    notifyListeners();
  }

  // Start the Flip Card Memory Game
  Future<void> startNewGame({
    required String topic,
    required String apiKey,
    required String aiProvider,
    required bool isOffline,
  }) async {
    _isLoadingCards = true;
    _isPlaying = false;
    _isWin = false;
    _timeElapsed = 0;
    _flipsCount = 0;
    _firstFlippedIndex = null;
    _isBusy = false;
    _currentTopic = topic;
    _deepSeekError = null; // Reset error at the start
    notifyListeners();

    try {
      List<Map<String, dynamic>> rawPairs;

      if (isOffline) {
        developer.log("Offline mode: Skipping AI API and loading local mock data directly.");
        rawPairs = _localDataService.getMockData(topic);
      } else {
        try {
          if (apiKey.isEmpty) {
            throw Exception("API Key của ${aiProvider.toUpperCase()} đang trống. Vui lòng vào Cài đặt để cấu hình.");
          }
          if (aiProvider == "gemini") {
            rawPairs = await _geminiService.getCardPairs(topic: topic, apiKey: apiKey);
          } else {
            rawPairs = await _deepSeekService.getCardPairs(topic: topic, apiKey: apiKey);
          }
        } catch (apiError) {
          developer.log("AI API call ($aiProvider) failed: $apiError. Falling back to local mock data.");
          _deepSeekError = apiError.toString().replaceAll("Exception: ", "");
          rawPairs = _localDataService.getMockData(topic);
        }
      }
      
      List<CardModel> loadedCards = [];
      int cardId = 0;
      int pairIndex = 1;
      
      for (var pair in rawPairs) {
        final matchId = pair['id'] as int? ?? pairIndex++;
        
        // Add card A (Term / Keyword)
        loadedCards.add(CardModel(
          id: cardId++,
          content: pair['card_a'] as String,
          matchId: matchId,
        ));
        
        // Add card B (Definition / Meaning)
        loadedCards.add(CardModel(
          id: cardId++,
          content: pair['card_b'] as String,
          matchId: matchId,
        ));
      }

      // Shuffle the cards list
      loadedCards.shuffle();
      _cards = loadedCards;
      
      _isLoadingCards = false;
      _isPlaying = true;
      _startTimer();
    } catch (e) {
      developer.log("Fatal error in starting new game: $e");
      _deepSeekError = "Lỗi khởi tạo màn chơi: $e";
      _isLoadingCards = false;
      _isPlaying = false;
    }
    notifyListeners();
  }

  // Handle Flip Card gesture
  void flipCard(int index) {
    if (!_isPlaying || _isWin || _isBusy) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    // Flip the tapped card
    _cards[index].isFlipped = true;
    notifyListeners();

    if (_firstFlippedIndex == null) {
      // This is the first card flipped
      _firstFlippedIndex = index;
    } else {
      // This is the second card flipped
      final int firstIndex = _firstFlippedIndex!;
      _flipsCount++;
      
      if (_cards[firstIndex].matchId == _cards[index].matchId) {
        // MATCH DETECTED!
        _cards[firstIndex].isMatched = true;
        _cards[index].isMatched = true;
        _firstFlippedIndex = null;
        
        // Check victory state
        _checkVictory();
      } else {
        // MISMATCH!
        _isBusy = true;
        notifyListeners();
        
        // Wait 900ms and flip them back down
        Timer(const Duration(milliseconds: 900), () {
          _cards[firstIndex].isFlipped = false;
          _cards[index].isFlipped = false;
          _firstFlippedIndex = null;
          _isBusy = false;
          notifyListeners();
        });
      }
    }
  }

  // Tick timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && !_isWin) {
        _timeElapsed++;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  // Check if all cards are matched
  void _checkVictory() {
    if (_cards.every((card) => card.isMatched)) {
      _isWin = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  // Calculate final score: (1000 - timeInSeconds) * 10 - (flipsCount * 5)
  int get finalScore {
    int timePenalty = _timeElapsed * 10;
    int flipPenalty = _flipsCount * 5;
    int score = 10000 - timePenalty - flipPenalty;
    return score > 0 ? score : 0;
  }

  // Save score to Firebase (online) and SharedPrefs (offline/local cache)
  Future<void> saveFinalScore(String username, bool isOffline) async {
    final score = ScoreModel(
      username: username,
      timeInSeconds: _timeElapsed,
      flipsCount: _flipsCount,
      score: finalScore,
      timestamp: DateTime.now(),
    );

    // 1. Luôn lưu vào Bảng xếp hạng cục bộ (SharedPrefs) trước để người chơi thấy điểm ngay lập tức
    _localLeaderboard.add(score);
    _localLeaderboard.sort((a, b) => b.score.compareTo(a.score));
    if (_localLeaderboard.length > 10) {
      _localLeaderboard = _localLeaderboard.sublist(0, 10);
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(
        _localLeaderboard.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('local_leaderboard', encodedData);
      notifyListeners();
      developer.log("Lưu điểm cục bộ thành công.");
    } catch (localError) {
      developer.log("Lỗi lưu điểm cục bộ: $localError");
    }

    // 2. Nếu ở chế độ Online và Firebase khả dụng, đồng bộ Firestore dưới nền (không chặn giao diện)
    if (!isOffline && _firebaseService.isAvailable) {
      developer.log("Đang đồng bộ điểm số lên Firestore dưới nền...");
      
      // Chạy bất đồng bộ và đặt giới hạn thời gian (timeout) 2 giây để tránh treo UI nếu Firestore bị tắt/lỗi quyền
      _firebaseService.saveScore(score).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          developer.log("Firestore lưu điểm bị quá hạn (Timeout). Hệ thống lưu offline cục bộ thành công.");
        },
      ).catchError((e) {
        developer.log("Lỗi đồng bộ điểm Firestore: $e");
      });
    }
  }

  // Cancel timer when disposing
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
