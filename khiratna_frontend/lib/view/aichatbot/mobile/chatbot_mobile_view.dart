import 'package:flutter/material.dart';
import '../widgets/chat_body.dart';

class ChatbotMobileView extends StatelessWidget {
  const ChatbotMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(top: false, child: ChatBody());
  }
}