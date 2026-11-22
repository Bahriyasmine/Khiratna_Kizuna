import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodel/chatbot_viewmodel.dart';
import 'chat_input_bar.dart';
import 'chat_messages_list.dart';
import 'suggestion_chips.dart';

const _green = Color(0xFF0F9D58);

class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatbotViewModel>();

    return Column(
      children: [
        Expanded(
          child: vm.messages.isEmpty
              ? _Welcome(onSelect: vm.sendMessage)
              : ChatMessagesList(
                  messages: vm.messages,
                  isTyping: vm.isTyping,
                ),
        ),
        ChatInputBar(
          enabled: !vm.isTyping,
          onSend: vm.sendMessage,
        ),
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const _Welcome({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.auto_awesome, color: _green, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Khiratna Assistant',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about crops, irrigation, soil and weather.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 28),
            SuggestionChips(
              suggestions: const [
                'Which crop suits my soil?',
                'When should I irrigate?',
                'What does soil salinity mean?',
                'How can I save water?',
              ],
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}