import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // Call Google Gemini API to get card pairs based on prompt
  Future<List<Map<String, dynamic>>> getCardPairs({
    required String topic,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception("API Key của Gemini đang trống. Vui lòng vào Cài đặt để cấu hình.");
    }

    final prompt = 
        "You are an API that generates card pairs for a flip memory game. "
        "Create exactly 8 card pairs (total 16 cards) related to the topic: '$topic'. "
        "Keep card content brief (1-3 words for card_a, 1-6 words for card_b) so it fits nicely on a mobile screen. "
        "You MUST return ONLY a clean, valid JSON object with the following exact structure, without any markdown formatting or ticks:\n"
        "{\n"
        "  \"pairs\": [\n"
        "    {\"card_a\": \"English Word or Term\", \"card_b\": \"Vietnamese Meaning or Definition\"},\n"
        "    ...\n"
        "  ]\n"
        "}\n"
        "Do not write any markdown code blocks (no ```json or ```), explanation text, or greetings outside of the JSON object.";

    final endpoints = [
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey",
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$apiKey",
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
      "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey",
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
    ];

    dynamic lastException;
    
    for (int i = 0; i < endpoints.length; i++) {
      final endpoint = endpoints[i];
      final url = Uri.parse(endpoint);
      developer.log("Calling Gemini API (Attempt ${i + 1}/${endpoints.length}): ${url.path}");
      
      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": prompt}
                ]
              }
            ],
            "generationConfig": {
              "responseMimeType": "application/json",
              "temperature": 0.7,
            }
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
          final String rawContent = data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
          
          developer.log("Raw response from Gemini: $rawContent");
          
          // Extract JSON from response
          final parsedPairs = _parseJsonContent(rawContent);
          if (parsedPairs != null && parsedPairs.isNotEmpty) {
            return parsedPairs;
          } else {
            throw Exception("Dữ liệu phản hồi từ AI không đúng cấu trúc JSON yêu cầu.");
          }
        } else {
          developer.log("Gemini API error (Status ${response.statusCode}): ${response.body}");
          lastException = Exception("Gemini API (Attempt ${i + 1}) trả về lỗi ${response.statusCode}. Vui lòng kiểm tra lại API Key.");
          
          // Try next endpoint if we get a 404 or transient error
          if (response.statusCode == 404 && i < endpoints.length - 1) {
            continue;
          } else {
            throw lastException;
          }
        }
      } catch (e) {
        developer.log("Error during Gemini attempt ${i + 1}: $e");
        lastException = e;
        if (i == endpoints.length - 1) {
          rethrow;
        }
      }
    }
    
    if (lastException != null) {
      throw lastException;
    }
    throw Exception("Không thể kết nối đến máy chủ Google Gemini. Vui lòng kiểm tra lại mạng hoặc API Key.");
  }

  // Parse JSON content carefully using Regular Expression
  List<Map<String, dynamic>>? _parseJsonContent(String rawText) {
    try {
      // Find the first '{' and last '}'
      final regex = RegExp(r'\{[\s\S]*\}');
      final match = regex.stringMatch(rawText);
      
      if (match != null) {
        final Map<String, dynamic> decoded = jsonDecode(match);
        if (decoded.containsKey('pairs')) {
          final List<dynamic> pairsJson = decoded['pairs'];
          return pairsJson.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
    } catch (e) {
      developer.log("JSON parsing error: $e");
    }
    return null;
  }
}
