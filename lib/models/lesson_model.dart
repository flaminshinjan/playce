import 'package:equatable/equatable.dart';

class LessonModel extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String videoUrl;
  final int duration; // in seconds
  final int order; // Changed back to 'order' to match the database
  final DateTime createdAt;
  final bool isCompleted;

  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.videoUrl,
    required this.duration,
    required this.order,
    required this.createdAt,
    this.isCompleted = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'duration': duration,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  LessonModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? videoUrl,
    int? duration,
    int? order,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return LessonModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        videoUrl,
        duration,
        order,
        createdAt,
        isCompleted,
      ];
} 