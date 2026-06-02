import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/score_model.dart';
import 'local_data_service.dart';

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
      
      // Auto sync predefined topics
      _syncPredefinedTopicsIfNeeded();
      
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

  // Fetch cards for a specific topic from Firestore (NoSQL online cards)
  Future<List<Map<String, dynamic>>?> getTopicCardsFromFirestore(String topicTitle) async {
    if (!_isAvailable) return null;
    try {
      final doc = await _firestore!.collection('topics').doc(topicTitle).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['cards'] != null) {
          final List<dynamic> rawCards = data['cards'];
          return rawCards.map((card) => Map<String, dynamic>.from(card)).toList();
        }
      }
    } catch (e) {
      developer.log("Error fetching topic cards from Firestore: $e");
    }
    return null;
  }

  // Get all topics metadata from Firestore (NoSQL online topic list)
  Future<List<Map<String, dynamic>>> getTopicsFromFirestore() async {
    if (!_isAvailable) return [];
    try {
      final snapshot = await _firestore!.collection('topics').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? doc.id,
          'icon': data['icon'] ?? 'help_outline_rounded',
          'color': data['color'] ?? 'primary',
          'description': data['description'] ?? '',
        };
      }).toList();
    } catch (e) {
      developer.log("Error getting topics from Firestore: $e");
      return [];
    }
  }

  // Auto sync predefined topics with their mock cards from LocalDataService to Firestore topics collection
  Future<void> _syncPredefinedTopicsIfNeeded() async {
    try {
      // Check if 'topics' collection has any document
      final snapshot = await _firestore!.collection('topics').limit(1).get();
      if (snapshot.docs.isEmpty) {
        developer.log("Firestore 'topics' collection is empty. Starting synchronization...");
        final localData = LocalDataService();
        final topics = localData.getPredefinedTopics();
        
        final batch = _firestore!.batch();
        for (var topic in topics) {
          final title = topic['title'] as String;
          final docRef = _firestore!.collection('topics').doc(title);
          final cards = localData.getMockData(title);
          
          batch.set(docRef, {
            'title': title,
            'icon': topic['icon'],
            'color': topic['color'],
            'description': topic['description'],
            'cards': cards,
            'syncedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        developer.log("Predefined topics synced to Firestore successfully.");
      } else {
        developer.log("Firestore 'topics' collection already has data. Skipping synchronization.");
      }
    } catch (e) {
      developer.log("Error syncing predefined topics to Firestore: $e");
    }
  }
}
