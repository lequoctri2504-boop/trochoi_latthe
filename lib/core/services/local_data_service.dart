class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  // Get list of predefined topics with icons and colors for Lobby Screen
  List<Map<String, dynamic>> getPredefinedTopics() {
    return [
      {
        "title": "OOP Programming",
        "icon": "code_rounded",
        "color": "primary",
        "description": "Lập trình hướng đối tượng",
      },
      {
        "title": "Thủ đô các nước",
        "icon": "public_rounded",
        "color": "secondary",
        "description": "Địa lý thế giới",
      },
      {
        "title": "Tiếng Anh giao tiếp",
        "icon": "translate_rounded",
        "color": "accent",
        "description": "Từ vựng & Mẫu câu",
      },
      {
        "title": "Lịch sử Việt Nam",
        "icon": "history_edu_rounded",
        "color": "orange",
        "description": "Sự kiện hào hùng lịch sử",
      },
      {
        "title": "Khoa học Vũ trụ",
        "icon": "auto_awesome_rounded",
        "color": "purple",
        "description": "Khám phá Thiên văn học",
      },
      {
        "title": "Thế giới Động vật",
        "icon": "pets_rounded",
        "color": "green",
        "description": "Khám phá thế giới hoang dã",
      },
      {
        "title": "Công nghệ & AI",
        "icon": "psychology_rounded",
        "color": "pink",
        "description": "Kỷ nguyên số hiện đại",
      },
    ];
  }

  // Get local mock card pairs for a specific topic
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

    // 3. Lịch sử Việt Nam
    if (topic.contains("lịch sử") || topic.contains("sử ta") || topic.contains("việt nam")) {
      return [
        {"id": 1, "card_a": "Ngô Quyền", "card_b": "Đại phá quân Nam Hán trên sông Bạch Đằng (938)"},
        {"id": 2, "card_a": "Hồ Chí Minh", "card_b": "Đọc bản Tuyên ngôn Độc lập tại Ba Đình (1945)"},
        {"id": 3, "card_a": "Điện Biên Phủ", "card_b": "Chiến dịch chấn động địa cầu, kết thúc kháng chiến Pháp (1954)"},
        {"id": 4, "card_a": "30/04/1975", "card_b": "Đại thắng Mùa Xuân giải phóng hoàn toàn miền Nam"},
        {"id": 5, "card_a": "Nguyễn Trãi", "card_b": "Soạn thảo bản Bình Ngô Đại Cáo hào hùng"},
        {"id": 6, "card_a": "Lý Thường Kiệt", "card_b": "Viết bản thơ thần Nam Quốc Sơn Hà khẳng định chủ quyền"},
        {"id": 7, "card_a": "Trần Hưng Đạo", "card_b": "Ba lần đại phá quân Nguyên Mông xâm lược"},
        {"id": 8, "card_a": "Hội nghị Diên Hồng", "card_b": "Ý chí quyết chiến đồng lòng của toàn dân thời nhà Trần"},
      ];
    }

    // 4. Khoa học Vũ trụ
    if (topic.contains("vũ trụ") || topic.contains("thiên văn") || topic.contains("sao")) {
      return [
        {"id": 1, "card_a": "Mặt Trời", "card_b": "Ngôi sao trung tâm cung cấp năng lượng cho Hệ Mặt Trời"},
        {"id": 2, "card_a": "Sao Hỏa", "card_b": "Hành tinh Đỏ đất đá có bầu khí quyển rất mỏng"},
        {"id": 3, "card_a": "Sao Mộc", "card_b": "Hành tinh khí khổng lồ lớn nhất trong hệ"},
        {"id": 4, "card_a": "Dải Ngân Hà", "card_b": "Thiên hà chứa toàn bộ Hệ Mặt Trời của chúng ta"},
        {"id": 5, "card_a": "Hố đen", "card_b": "Vùng không-thời gian có lực hấp dẫn cực đại ánh sáng không thoát được"},
        {"id": 6, "card_a": "Mặt Trăng", "card_b": "Vệ tinh tự nhiên duy nhất quay quanh Trái Đất"},
        {"id": 7, "card_a": "Sao Thổ", "card_b": "Hành tinh khí có hệ vành đai băng đá lớn và đẹp mắt"},
        {"id": 8, "card_a": "Big Bang", "card_b": "Thuyết vụ nổ lớn khởi đầu cho sự hình thành Vũ Trụ"},
      ];
    }

    // 5. Thế giới Động vật
    if (topic.contains("động vật") || topic.contains("thú") || topic.contains("loài vật") || topic.contains("pets")) {
      return [
        {"id": 1, "card_a": "Sư tử", "card_b": "Chúa tể thống trị thảo nguyên châu Phi"},
        {"id": 2, "card_a": "Cá voi xanh", "card_b": "Động vật lớn nhất từng tồn tại trên hành tinh"},
        {"id": 3, "card_a": "Báo săn", "card_b": "Động vật chạy nhanh nhất trên mặt đất phẳng"},
        {"id": 4, "card_a": "Chim cánh cụt", "card_b": "Loài chim không biết bay thích nghi tuyệt đối ở Nam Cực"},
        {"id": 5, "card_a": "Lạc đà", "card_b": "Người bạn đồng hành sa mạc tích nước trong bướu"},
        {"id": 6, "card_a": "Gấu trúc", "card_b": "Biểu tượng bảo tồn thiên nhiên thế giới, chỉ ăn lá tre"},
        {"id": 7, "card_a": "Hươu cao cổ", "card_b": "Động vật có chiều cao lớn nhất trên mặt đất"},
        {"id": 8, "card_a": "Cá heo", "card_b": "Loài thú biển thông minh và thân thiện nhất với con người"},
      ];
    }

    // 6. Công nghệ & AI
    if (topic.contains("công nghệ") || topic.contains("ai") || topic.contains("trí tuệ nhân tạo") || topic.contains("tech")) {
      return [
        {"id": 1, "card_a": "Trí tuệ nhân tạo", "card_b": "Hệ thống máy tính mô phỏng trí thông minh con người"},
        {"id": 2, "card_a": "Điện toán đám mây", "card_b": "Cung cấp lưu trữ và tính toán từ xa qua Internet"},
        {"id": 3, "card_a": "Blockchain", "card_b": "Sổ cái điện tử phi tập trung, bất biến độ bảo mật cao"},
        {"id": 4, "card_a": "Big Data", "card_b": "Tập hợp dữ liệu quy mô khổng lồ cần kỹ thuật xử lý đặc biệt"},
        {"id": 5, "card_a": "IoT", "card_b": "Mạng lưới kết nối vạn vật vật lý vào Internet"},
        {"id": 6, "card_a": "Thực tế ảo (VR)", "card_b": "Môi trường giả lập 3D giúp người dùng tương tác nhập vai"},
        {"id": 7, "card_a": "An ninh mạng", "card_b": "Lĩnh vực bảo vệ dữ liệu và hệ thống khỏi hacker"},
        {"id": 8, "card_a": "Machine Learning", "card_b": "Nhánh AI giúp máy tính tự học hỏi thông minh từ dữ liệu lớn"},
      ];
    }

    // Default: Tiếng Anh giao tiếp
    return [
      {"id": 1, "card_a": "Hello", "card_b": "Xin chào"},
      {"id": 2, "card_a": "Thank you", "card_b": "Cảm ơn bạn rất nhiều"},
      {"id": 3, "card_a": "Excuse me", "card_b": "Xin lỗi cho tôi hỏi / làm phiền"},
      {"id": 4, "card_a": "Nice to meet you", "card_b": "Rất vui được gặp bạn"},
      {"id": 5, "card_a": "How are you?", "card_b": "Bạn khỏe không?"},
      {"id": 6, "card_a": "You are welcome", "card_b": "Không có chi / Bạn luôn được hoan nghênh"},
      {"id": 7, "card_a": "See you later", "card_b": "Hẹn gặp lại bạn sau nhé"},
      {"id": 8, "card_a": "Have a nice day", "card_b": "Chúc bạn một ngày mới tốt lành"},
    ];
  }
}
