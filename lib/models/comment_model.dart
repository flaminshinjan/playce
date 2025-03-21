import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.userAvatarUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Provide default values for nullable fields
    return CommentModel(
      id: json['id'] as String? ?? '', // Handle potentially null ID
      postId: json['post_id'] as String? ?? '', // Handle potentially null post_id
      userId: json['user_id'] as String? ?? '', // Handle potentially null user_id
      username: json['username'] as String? ?? 'Unknown User', // Default username
      userAvatarUrl: json['user_avatar_url'] as String?, // This is already nullable
      content: json['content'] as String? ?? '', // Default empty content
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String) 
        : DateTime.now(), // Default current time
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'] as String) 
        : DateTime.now(), // Default current time
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'username': username,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? userAvatarUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        username,
        userAvatarUrl,
        content,
        createdAt,
        updatedAt,
      ];
} 