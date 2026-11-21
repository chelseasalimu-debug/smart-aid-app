import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/ai_service.dart';
import '../services/chat_history_service.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final ChatSession? existingSession;
  const ChatScreen({super.key, this.existingSession});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  late String _sessionId;
  late DateTime _createdAt;
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingSession != null) {
      // Continue an existing conversation
      _sessionId = widget.existingSession!.id;
      _createdAt = widget.existingSession!.createdAt;
      _messages.addAll(widget.existingSession!.messages);
    } else {
      // New session
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _createdAt = DateTime.now();
      _messages.add(
        ChatMessage(
          text:
              "Hi! I'm SmartAID. Describe the situation — for example: "
              "'My friend cut his hand and it won't stop bleeding.'\n\n"
              "⚠️ I give first-aid guidance only, not medical diagnosis.",
          isUser: false,
        ),
      );
    }
  }

  Future<void> _persistSession() async {
    final session = ChatSession(
      id: _sessionId,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
      title: ChatHistoryService.generateTitle(_messages),
      messages: _messages,
    );
    await ChatHistoryService.save(session);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _loading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await AIService.getFirstAidGuidance(text);
      if (!mounted) return;
      setState(() => _messages.add(ChatMessage(text: reply, isUser: false)));
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _messages.add(
          ChatMessage(
            text: '⚠️ Sorry, something went wrong. Please try again.\n\n$e',
            isUser: false,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _scrollToBottom();
      }
    }

    // Save after every exchange
    await _persistSession();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Describe your situation')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _Bubble(message: _messages[i]),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe what happened...',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isUser
            ? Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),
      ),
    );
  }
}
