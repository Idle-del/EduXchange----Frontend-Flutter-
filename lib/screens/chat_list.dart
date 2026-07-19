// ignore_for_file: deprecated_member_use

import 'package:edu_xchange/model/user.dart';
import 'package:edu_xchange/screens/chat_screen.dart';
import 'package:edu_xchange/services/user_service.dart';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/services/chat_service.dart';
import 'package:edu_xchange/services/token_service.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  int? currentUserId;

  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final userId = await TokenService().getUserId();
    if (!mounted) return;

    setState(() => currentUserId = userId);
  }

  /// Formats a message timestamp for the chat list trailing label:
  /// "10:32 AM" for today, "Mon" for the last week, or "Jul 18" otherwise.
  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final isToday =
        timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;

    if (isToday) {
      final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }

    final difference = now.difference(timestamp).inDays;
    if (difference < 7) {
      const weekdays = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];
      return weekdays[timestamp.weekday - 1];
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[timestamp.month - 1]} ${timestamp.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUserId == null) {
      return const Center(child: CircularProgressIndicator(color: _primaryColor));
    }
    return StreamBuilder(
      stream: _chatService.getChats(currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _primaryColor));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No chats available.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          );
        }

        final chats = snapshot.data!;

        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 78,
            color: isDark ? Colors.grey[850] : Colors.grey[200],
          ),
          itemBuilder: (context, index) {
            final chat = chats[index];
            final otherUserId = chat.participants.firstWhere(
              (id) => id != currentUserId,
            );
            final isUnread = chat.isUnreadFor(currentUserId!);

            return FutureBuilder<User>(
              future: _userService.getUserDetails(otherUserId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(title: Text('Loading...'));
                }

                if (userSnapshot.hasError) {
                  return ListTile(
                    title: Text(userSnapshot.error.toString()),
                  );
                }

                final user = userSnapshot.data!;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: _primaryColor.withOpacity(0.1),
                    backgroundImage: user.profilePicture != null
                        ? NetworkImage(
                            '${ApiConstants.serverUrl}${user.profilePicture}',
                          )
                        : null,
                    child: user.profilePicture == null
                        ? const Icon(Icons.person, color: _primaryColor)
                        : null,
                  ),
                  title: Text(
                    user.fullName,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      color: isUnread
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTimestamp(chat.lastMessageTimestamp),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          color: isUnread
                              ? _primaryColor
                              : (isDark ? Colors.grey[500] : Colors.grey[600]),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          currentUserId: currentUserId!,
                          receiverUserId: user.id,
                          receiverUserName: user.fullName,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}