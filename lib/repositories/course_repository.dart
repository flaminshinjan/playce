import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

class CourseRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<CourseModel>> getCourses() async {
    final response = await _supabaseClient
        .from('courses')
        .select('*, lessons(*)')
        .order('created_at');

    return (response as List)
        .map((course) => CourseModel.fromJson(course))
        .toList();
  }

  Future<CourseModel> getCourseById(String courseId) async {
    final response = await _supabaseClient
        .from('courses')
        .select('*, lessons(*)')
        .eq('id', courseId)
        .single();

    return CourseModel.fromJson(response);
  }

  Future<CourseModel> createCourse(String title, String? description, String? thumbnailUrl, String? category) async {
    final response = await _supabaseClient.from('courses').insert({
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'category': category,
      'created_at': DateTime.now().toIso8601String(),
    }).select('*, lessons(*)').single();

    return CourseModel.fromJson(response);
  }

  Future<LessonModel> addLesson(String courseId, String title, String videoUrl, {String? description}) async {
    final response = await _supabaseClient.from('lessons').insert({
      'course_id': courseId,
      'title': title,
      'video_url': videoUrl,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
      'order': await _getNextLessonOrder(courseId),
    }).select().single();

    // Update total_lessons count in the course
    await _supabaseClient.from('courses').update({
      'total_lessons': await _getLessonCount(courseId),
    }).eq('id', courseId);

    return LessonModel.fromJson(response);
  }

  Future<int> _getNextLessonOrder(String courseId) async {
    final response = await _supabaseClient
        .from('lessons')
        .select('order')
        .eq('course_id', courseId)
        .order('order', ascending: false)
        .limit(1)
        .maybeSingle();

    return (response != null ? response['order'] as int : -1) + 1;
  }

  Future<int> _getLessonCount(String courseId) async {
    final response = await _supabaseClient
        .from('lessons')
        .select('id')
        .eq('course_id', courseId);

    return (response as List).length;
  }

  Future<void> updateLesson(String lessonId, {String? title, String? videoUrl, String? description}) async {
    final updates = {
      if (title != null) 'title': title,
      if (videoUrl != null) 'video_url': videoUrl,
      if (description != null) 'description': description,
    };

    await _supabaseClient
        .from('lessons')
        .update(updates)
        .eq('id', lessonId);
  }

  Future<void> deleteCourse(String courseId) async {
    await _supabaseClient.from('courses').delete().eq('id', courseId);
  }

  Future<void> deleteLesson(String lessonId, String courseId) async {
    await _supabaseClient.from('lessons').delete().eq('id', lessonId);
    
    // Update total_lessons count in the course
    await _supabaseClient.from('courses').update({
      'total_lessons': await _getLessonCount(courseId),
    }).eq('id', courseId);
  }
} 