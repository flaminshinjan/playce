import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String caption;
  final String? imageUrl;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.caption,
    this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: (json['userId'] ?? json['user_id']) as String,
      username: json['username'] as String,
      userAvatarUrl: (json['userAvatarUrl'] ?? json['user_avatar_url']) as String,
      caption: json['caption'] as String,
      imageUrl: (json['imageUrl'] ?? json['image_url']) as String?,
      createdAt: DateTime.parse((json['createdAt'] ?? json['created_at']) as String),
      likeCount: (json['likeCount'] ?? json['like_count']) as int,
      commentCount: (json['commentCount'] ?? json['comment_count']) as int,
      isLiked: (json['isLiked'] ?? json['is_liked'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'caption': caption,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarUrl,
    String? caption,
    String? imageUrl,
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Increments comment count by 1
  PostModel incrementCommentCount() {
    return copyWith(
      commentCount: commentCount + 1,
    );
  }

  // Decrements comment count by 1 (with validation to prevent negative values)
  PostModel decrementCommentCount() {
    return copyWith(
      commentCount: commentCount > 0 ? commentCount - 1 : 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        userAvatarUrl,
        caption,
        imageUrl,
        createdAt,
        likeCount,
        commentCount,
        isLiked,
      ];
} 