import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/chatbot_viewmodel.dart';
import 'mobile/chatbot_mobile_view.dart';
import 'web/chatbot_web_view.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatbotViewModel(),
      child: const _ChatbotLayout(),
    );
  }
}

// Separate widget so the app bar can read the provider created above.
class _ChatbotLayout extends StatelessWidget {
  const _ChatbotLayout();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatbotViewModel>();
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (vm.messages.isNotEmpty)
            IconButton(
              tooltip: 'New chat',
              icon: const Icon(Icons.refresh),
              onPressed: vm.clearChat,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: isWeb ? const ChatbotWebView() : const ChatbotMobileView(),
    );
  }
}