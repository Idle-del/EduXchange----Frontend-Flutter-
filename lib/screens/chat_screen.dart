import 'package:edu_xchange/model/chat_message.dart';
import 'package:edu_xchange/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final int currentUserId;
  final int receiverUserId;
  final String receiverUserName;
  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.receiverUserId,
    required this.receiverUserName
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  late final String _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = _chatService.getRoomId(
      widget.currentUserId,
      widget.receiverUserId,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    _chatService.sendMessage(
      _chatId,
      widget.currentUserId,
      widget.receiverUserId,
      message,
    );
    _messageController.clear();
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.message,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.getMessages(_chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }
        final messages = snapshot.data!;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == widget.currentUserId;
            return _buildMessageBubble(message, isMe);
          },
        );
      },
    );
  }

  Widget buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUserName)),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          buildMessageInput(),
        ],
      ),
    );
  }
}
