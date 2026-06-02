import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/score_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  // Safe initialization of Firebase to prevent crashes if not configured yet
  Future<bool> initialize() async {
    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isAvailable = true;
      developer.log("Firebase initialized successfully.");
      return true;
    } catch (e) {
      _isAvailable = false;
      developer.log("Firebase not configured or failed to initialize: $e. Falling back to Offline Mode.");
      return false;
    }
  }

  // --- Authentication ---
  
  User? get currentUser => _isAvailable ? _auth!.currentUser : null;

  Stream<User?> authStateChanges() {
    if (!_isAvailable) return const Stream.empty();
    return _auth!.authStateChanges();
  }

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    if (!_isAvailable) throw Exception("Firebase is not available.");
    return await _auth!.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (!_isAvailable) throw Exception("Firebase is not available.");
    return await _auth!.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInAnonymously() async {
    if (!_isAvailable) throw Exception("Firebase is not available.");
    return await _auth!.signInAnonymously();
  }

  Future<void> signOut() async {
    if (!_isAvailable) return;
    await _auth!.signOut();
  }

  // --- Firestore Leaderboard ---

  Future<void> saveScore(ScoreModel score) async {
    if (!_isAvailable) return;
    try {
      await _firestore!.collection('leaderboard').add(score.toJson());
      developer.log("Score saved successfully to Firestore.");
    } catch (e) {
      developer.log("Error saving score to Firestore: $e");
    }
  }

  Stream<List<ScoreModel>> getGlobalLeaderboard() {
    if (!_isAvailable) return Stream.value([]);
    return _firestore!
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScoreModel.fromFirestore(doc.data());
      }).toList();
    });
  }
}
