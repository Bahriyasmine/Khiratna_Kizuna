import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/chat_message.dart';
import '../services/chatbot_service.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotService _service = ChatbotService();

  final List<ChatMessage> messages = [];
  bool isTyping = false;
  bool _disposed = false;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping) return;

    messages.add(ChatMessage(text: trimmed, isUser: true));
    isTyping = true;
    notifyListeners();

    try {
      final reply = await _service.ask(trimmed);
      messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      debugPrint('Chatbot Error: $e');
      messages.add(ChatMessage(
        text: _errorMessage(e),
        isUser: false,
        isError: true,
      ));
    } finally {
      isTyping = false;
      if (!_disposed) notifyListeners();
    }
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 503) {
        return 'The assistant is busy right now. Please try again in a moment.';
      }
      if (e.response == null) {
        return 'Could not reach the server. Check your connection.';
      }
    }
    return 'Sorry, something went wrong. Please try again.';
  }

  void clearChat() {
    messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}