import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByMe;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showAvatar;
  final String? senderAvatarUrl;
  final String senderName;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isSentByMe,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.showAvatar = true,
    this.senderAvatarUrl,
    this.senderName = 'User',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate border radius based on position in the group
    final bubbleRadius = BorderRadius.only(
      topLeft: Radius.circular(!isSentByMe && isFirstInGroup ? 4 : 16),
      topRight: Radius.circular(isSentByMe && isFirstInGroup ? 4 : 16),
      bottomLeft: Radius.circular(!isSentByMe && isLastInGroup ? 16 : 4),
      bottomRight: Radius.circular(isSentByMe && isLastInGroup ? 16 : 4),
    );
    
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 8 : 2,
        bottom: isLastInGroup ? 8 : 2,
        left: 4,
        right: 4,
      ),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar - only shown for received messages and at the end of a group
          if (!isSentByMe && showAvatar)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryVariant,
              backgroundImage: senderAvatarUrl != null
                  ? NetworkImage(senderAvatarUrl!)
                  : null,
              child: senderAvatarUrl == null
                  ? Text(
                      senderName.isNotEmpty ? senderName.substring(0, 1).toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.buttonText,
                        fontSize: 12,
                      ),
                    )
                  : null,
            )
          else if (!isSentByMe)
            const SizedBox(width: 32), // Space for avatar alignment
            
          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender name (only for first message in group from others)
                if (!isSentByMe && isFirstInGroup && senderName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                // Message bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSentByMe 
                        ? AppColors.primary 
                        : AppColors.surface,
                    borderRadius: bubbleRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isSentByMe ? AppColors.buttonText : AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: TextStyle(
                              color: isSentByMe 
                                  ? AppColors.buttonText.withOpacity(0.7) 
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          if (isSentByMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 12,
                              color: message.isRead
                                  ? AppColors.buttonText
                                  : AppColors.buttonText.withOpacity(0.6),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Extra space for sent messages (to balance avatar space)
          if (isSentByMe) const SizedBox(width: 32),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    // Format just the time part
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    // Today - just show time
    if (messageDate == today) {
      return timeStr;
    } 
    // Yesterday - show "Yesterday" and time
    else if (messageDate == yesterday) {
      return 'Yesterday $timeStr';
    } 
    // This week - show day name and time
    else if (now.difference(messageDate).inDays < 7) {
      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateTime.weekday - 1];
      return '$dayName $timeStr';
    } 
    // Older - show date and time
    else {
      return '${dateTime.day}/${dateTime.month} $timeStr';
    }
  }
} 