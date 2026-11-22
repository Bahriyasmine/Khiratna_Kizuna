import 'package:flutter/material.dart';
import '../widgets/chat_body.dart';

class ChatbotWebView extends StatelessWidget {
  const ChatbotWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ChatBody(),
        ),
      ),
    );
  }
}