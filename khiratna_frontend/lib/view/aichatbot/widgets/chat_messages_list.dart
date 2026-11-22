import 'package:flutter/material.dart';
import '../../../model/chat_message.dart';
import 'message_bubble.dart';
import 'typing_indicator.dart';

class ChatMessagesList extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatMessagesList({
    super.key,
    required this.messages,
    required this.isTyping,
  });

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList> {
  final ScrollController _controller = ScrollController();
  int _lastCount = 0;

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.messages.length + (widget.isTyping ? 1 : 0);
    if (count != _lastCount) {
      _lastCount = count;
      _scrollToEnd();
    }

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: count,
      itemBuilder: (context, index) {
        if (index == widget.messages.length) {
          return const TypingBubble();
        }
        return MessageBubble(message: widget.messages[index]);
      },
    );
  }
}