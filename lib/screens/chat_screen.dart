// ignore_for_file: deprecated_member_use

import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/model/chat_message.dart';
import 'package:edu_xchange/model/user.dart';
import 'package:edu_xchange/services/chat_service.dart';
import 'package:edu_xchange/services/user_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final int currentUserId;
  final int receiverUserId;
  final String receiverUserName;
  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.receiverUserId,
    required this.receiverUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final TextEditingController _messageController = TextEditingController();

  late final String _chatId;
  late final Future<User> _receiverFuture;

  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue

  @override
  void initState() {
    super.initState();
    _chatId = _chatService.getRoomId(
      widget.currentUserId,
      widget.receiverUserId,
    );
    _receiverFuture = _userService.getUserDetails(widget.receiverUserId);
    // Mark the latest message as read now that the user has opened the chat.
    _chatService.markChatAsRead(_chatId, widget.currentUserId);
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

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? _primaryColor
              : (isDark ? const Color(0xFF1E2A3D) : Colors.grey.shade200),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10.5,
                color: isMe
                    ? Colors.white.withOpacity(0.75)
                    : (isDark ? Colors.grey[500] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(bool isDark) {
    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.getMessages(_chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _primaryColor));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No messages yet',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          );
        }
        final messages = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == widget.currentUserId;
            return _buildMessageBubble(message, isMe, isDark);
          },
        );
      },
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0E1420) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF161D2B) : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E1420) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E1420) : Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: FutureBuilder<User>(
          future: _receiverFuture,
          builder: (context, snapshot) {
            final profilePicture = snapshot.data?.profilePicture;

            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _primaryColor.withOpacity(0.1),
                  backgroundImage: profilePicture != null
                      ? NetworkImage(
                          '${ApiConstants.serverUrl}$profilePicture',
                        )
                      : null,
                  child: profilePicture == null
                      ? const Icon(Icons.person, color: _primaryColor, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.receiverUserName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : _primaryColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(isDark)),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }
}