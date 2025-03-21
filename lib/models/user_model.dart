import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final bool isParent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? childrenIds;

  const UserModel({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.isParent = false,
    this.createdAt,
    this.updatedAt,
    this.childrenIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      isParent: json['is_parent'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      childrenIds: json['children_ids'] != null
          ? List<String>.from(json['children_ids'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_parent': isParent,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    
    // Only include childrenIds if it's not null
    if (childrenIds != null) {
      json['children_ids'] = childrenIds;
    }
    
    return json;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    bool? isParent,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? childrenIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isParent: isParent ?? this.isParent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      childrenIds: childrenIds ?? this.childrenIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        fullName,
        avatarUrl,
        bio,
        isParent,
        createdAt,
        updatedAt,
        childrenIds,
      ];
} 