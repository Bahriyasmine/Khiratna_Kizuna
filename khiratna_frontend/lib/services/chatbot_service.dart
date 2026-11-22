import 'package:dio/dio.dart';
import 'package:khiratna_frontend/core/network/api_client.dart';

class ChatbotService {
  Future<String> ask(String question) async {
    final response = await ApiClient.dio.post(
      '/farm/chat',
      data: {'question': question},
      // The AI can be slow, so allow more than the default 15s
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );

    final answer = (response.data['answer'] ?? '').toString();
    return answer.isEmpty ? 'I could not find an answer to that.' : answer;
  }
}