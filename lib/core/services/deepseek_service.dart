import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class DeepSeekService {
  static final DeepSeekService _instance = DeepSeekService._internal();
  factory DeepSeekService() => _instance;
  DeepSeekService._internal();

  // Call DeepSeek API to get card pairs based on prompt
  Future<List<Map<String, dynamic>>> getCardPairs({
    required String topic,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception("API Key của DeepSeek đang trống. Vui lòng vào Cài đặt để cấu hình.");
    }

    final url = Uri.parse("https://api.deepseek.com/v1/chat/completions");
    
    final systemPrompt = 
        "You are an API that generates card pairs for a flip memory game. "
        "Create exactly 8 card pairs (total 16 cards) related to the topic provided by the user. "
        "Keep card content brief (1-3 words for card_a, 1-6 words for card_b) so it fits nicely on a mobile screen. "
        "You MUST return ONLY a clean, valid JSON object with the following exact structure:\n"
        "{\n"
        "  \"pairs\": [\n"
        "    {\"card_a\": \"English Word or Term\", \"card_b\": \"Vietnamese Meaning or Definition\"},\n"
        "    ...\n"
        "  ]\n"
        "}\n"
        "Do not write any markdown code blocks, explanation text, or greetings outside of the JSON object.";

    final userPrompt = "Create 8 memory game card pairs for topic: '$topic'";

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userPrompt}
          ],
          "temperature": 0.7,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final String rawContent = data['choices'][0]['message']['content'].toString().trim();
        
        developer.log("Raw response from DeepSeek: $rawContent");
        
        // Extract JSON from response
        final parsedPairs = _parseJsonContent(rawContent);
        if (parsedPairs != null && parsedPairs.isNotEmpty) {
          return parsedPairs;
        } else {
          throw Exception("Dữ liệu phản hồi từ AI không đúng cấu trúc JSON yêu cầu.");
        }
      } else {
        developer.log("DeepSeek API error: ${response.statusCode} - ${response.body}");
        throw Exception("API trả về lỗi ${response.statusCode}. Bạn vui lòng kiểm tra lại tài khoản DeepSeek (số dư hoặc tính hợp lệ của API Key).");
      }
    } catch (e) {
      developer.log("Error calling DeepSeek API: $e");
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Lỗi kết nối mạng: Không thể kết nối tới máy chủ DeepSeek. Chi tiết: $e");
    }
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

  // Mock data generator for offline/fallback mode
  List<Map<String, dynamic>> getMockData(String topic) {
    topic = topic.toLowerCase();
    
    // 1. OOP Programming
    if (topic.contains("oop") || topic.contains("lập trình") || topic.contains("đối tượng") || topic.contains("it")) {
      return [
        {"id": 1, "card_a": "Class", "card_b": "Khuôn mẫu thiết kế đối tượng"},
        {"id": 2, "card_a": "Object", "card_b": "Một thực thể được tạo ra từ Class"},
        {"id": 3, "card_a": "Encapsulation", "card_b": "Tính đóng gói (Che giấu dữ liệu)"},
        {"id": 4, "card_a": "Inheritance", "card_b": "Tính kế thừa (Tái sử dụng mã nguồn)"},
        {"id": 5, "card_a": "Polymorphism", "card_b": "Tính đa hình (Nhiều hình thái phương thức)"},
        {"id": 6, "card_a": "Abstraction", "card_b": "Tính trừu tượng (Ẩn chi tiết cài đặt)"},
        {"id": 7, "card_a": "Constructor", "card_b": "Hàm đặc biệt để khởi tạo đối tượng"},
        {"id": 8, "card_a": "Interface", "card_b": "Ký hợp ước quy định các phương thức"},
      ];
    }
    
    // 2. Geography / Countries
    if (topic.contains("thủ đô") || topic.contains("địa lý") || topic.contains("nước")) {
      return [
        {"id": 1, "card_a": "Việt Nam", "card_b": "Hà Nội"},
        {"id": 2, "card_a": "Nhật Bản", "card_b": "Tokyo"},
        {"id": 3, "card_a": "Hàn Quốc", "card_b": "Seoul"},
        {"id": 4, "card_a": "Mỹ", "card_b": "Washington D.C."},
        {"id": 5, "card_a": "Pháp", "card_b": "Paris"},
        {"id": 6, "card_a": "Anh", "card_b": "London"},
        {"id": 7, "card_a": "Thái Lan", "card_b": "Bangkok"},
        {"id": 8, "card_a": "Úc", "card_b": "Canberra"},
      ];
    }

    // Default: English Vocabulary
    return [
      {"id": 1, "card_a": "Hello", "card_b": "Xin chào"},
      {"id": 2, "card_a": "Library", "card_b": "Thư viện"},
      {"id": 3, "card_a": "Developer", "card_b": "Nhà phát triển phần mềm"},
      {"id": 4, "card_a": "Memory", "card_b": "Bộ nhớ / Trí nhớ"},
      {"id": 5, "card_a": "Challenge", "card_b": "Thử thách"},
      {"id": 6, "card_a": "Database", "card_b": "Cơ sở dữ liệu"},
      {"id": 7, "card_a": "Mobile App", "card_b": "Ứng dụng di động"},
      {"id": 8, "card_a": "Success", "card_b": "Thành công rực rỡ"},
    ];
  }
}
