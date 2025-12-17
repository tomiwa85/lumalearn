import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIService {
  // 🔴 IMPORTANT: Replace this URL with your ACTUAL Render URL
  // It usually looks like: https://your-app-name.onrender.com/chat
  // static const String _serverUrl = "https://luma-ai.onrender.com/chat";

  // For Android Emulator use: http://10.0.2.2:8000/chat
  // For iOS Simulator / Web / Windows use: http://127.0.0.1:8000/chat
  // For Physical Device (LAN): http://192.168.0.133:8000/chat
  static const String _serverUrl = "https://lumalearn-full.onrender.com/chat";

  // Function to send message to Render and get Llama 3's reply
  Future<String> getAIResponse(
      String userMessage, String sessionId, String subject) async {
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "session_id": sessionId,
          "message": userMessage,
          "subject": subject,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response']; // The text from Llama 3
      } else {
        return "I am having trouble connecting to the brain (Error ${response.statusCode}).";
      }
    } catch (e) {
      // This happens if your phone has no internet or the server is down
      return "Network Error. Please check your internet connection.";
    }
  }
}

// Provider to allow other files to use this service
final aiServiceProvider = Provider((ref) => AIService());
