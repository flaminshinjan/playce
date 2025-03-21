import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? senderUsername; // Additional field for displaying
  final String? senderAvatarUrl; // Additional field for displaying

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.senderUsername,
    this.senderAvatarUrl,
  });

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    String? senderUsername,
    String? senderAvatarUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      senderUsername: senderUsername ?? this.senderUsername,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data from the join query
    String? senderUsername;
    String? senderAvatarUrl;
    
    // Get sender data from the nested 'sender' object if it exists
    if (json['sender'] is Map) {
      senderUsername = json['sender']['username'];
      senderAvatarUrl = json['sender']['avatar_url'];
    } else {
      // Fallback to legacy fields if they exist
      senderUsername = json['sender_username'];
      senderAvatarUrl = json['sender_avatar_url'];
    }
    
    return MessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      senderUsername: senderUsername,
      senderAvatarUrl: senderAvatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'sender_username': senderUsername,
      'sender_avatar_url': senderAvatarUrl,
    };
  }

  @override
  List<Object?> get props => [
    id, 
    senderId, 
    receiverId, 
    content, 
    createdAt, 
    isRead,
    senderUsername,
    senderAvatarUrl
  ];
} 