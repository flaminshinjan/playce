import 'package:equatable/equatable.dart';

import 'lesson_model.dart';

class CourseModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final List<LessonModel>? lessons;
  final DateTime createdAt;
  final String? category;
  final int totalLessons;
  final bool isRecommended;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.lessons,
    required this.createdAt,
    this.category,
    this.totalLessons = 0,
    this.isRecommended = false,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    List<LessonModel>? lessonsList;
    
    if (json['lessons'] != null) {
      lessonsList = (json['lessons'] as List)
          .map((item) => LessonModel.fromJson(item))
          .toList();
    }
    
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      lessons: lessonsList,
      createdAt: DateTime.parse(json['created_at']),
      category: json['category'],
      totalLessons: json['total_lessons'] ?? 0,
      isRecommended: json['is_recommended'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'category': category,
      'total_lessons': totalLessons,
      'is_recommended': isRecommended,
    };
    
    if (lessons != null) {
      data['lessons'] = lessons!.map((lesson) => lesson.toJson()).toList();
    }
    
    return data;
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    List<LessonModel>? lessons,
    DateTime? createdAt,
    String? category,
    int? totalLessons,
    bool? isRecommended,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      lessons: lessons ?? this.lessons,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      totalLessons: totalLessons ?? this.totalLessons,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnailUrl,
        lessons,
        createdAt,
        category,
        totalLessons,
        isRecommended,
      ];
} 