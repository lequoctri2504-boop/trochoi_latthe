import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreModel {
  final String username;
  final int timeInSeconds;
  final int flipsCount;
  final int score;
  final DateTime timestamp;

  ScoreModel({
    required this.username,
    required this.timeInSeconds,
    required this.flipsCount,
    required this.score,
    required this.timestamp,
  });

  // Convert to JSON to save to Firestore / Local Storage
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'timeInSeconds': timeInSeconds,
      'flipsCount': flipsCount,
      'score': score,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert from Firestore DocumentSnapshot
  factory ScoreModel.fromFirestore(Map<String, dynamic> json) {
    DateTime parsedTime;
    if (json['timestamp'] is Timestamp) {
      parsedTime = (json['timestamp'] as Timestamp).toDate();
    } else {
      parsedTime = DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now();
    }
    
    return ScoreModel(
      username: json['username'] ?? 'Người chơi ẩn danh',
      timeInSeconds: json['timeInSeconds'] ?? 0,
      flipsCount: json['flipsCount'] ?? 0,
      score: json['score'] ?? 0,
      timestamp: parsedTime,
    );
  }

  // Convert from standard JSON (for SharedPreferences / Local storage)
  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      username: json['username'] ?? 'Người chơi ẩn danh',
      timeInSeconds: json['timeInSeconds'] ?? 0,
      flipsCount: json['flipsCount'] ?? 0,
      score: json['score'] ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
