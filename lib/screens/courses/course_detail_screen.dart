import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/course_model.dart';
import 'package:playce/models/lesson_model.dart';
import 'package:playce/screens/courses/lesson_screen.dart';
import 'package:playce/services/supabase_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _supabaseService = SupabaseService();
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  CourseModel? _course;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
      final course = await _supabaseService.getCourseById(widget.courseId);
      if (mounted) {
        setState(() {
          _course = course;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _hasError
              ? _buildErrorView()
              : _buildCourseDetailView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load course',
              style: AppTextStyles.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCourseDetails,
              child: const Text('Retry'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDetailView() {
    final course = _course!;
    final lessons = course.lessons ?? [];

    return CustomScrollView(
      slivers: [
        // Course Header with Image
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.background,
          flexibleSpace: FlexibleSpaceBar(
            background: course.thumbnailUrl != null
                ? Image.network(
                    course.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.school,
                            size: 64,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.school,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Course Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.category != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course.category!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  course.title,
                  style: AppTextStyles.headline2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${course.totalLessons} ${course.totalLessons == 1 ? 'Lesson' : 'Lessons'}',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (course.description != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'About this course',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description!,
                    style: AppTextStyles.bodyText1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Lessons',
                  style: AppTextStyles.headline3,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Lessons List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final lesson = lessons[index];
              return _buildLessonTile(lesson, index);
            },
            childCount: lessons.length,
          ),
        ),

        SliverToBoxAdapter(
          child: const SizedBox(height: 40),
        ),
      ],
    );
  }

  Widget _buildLessonTile(LessonModel lesson, int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
         
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Lesson Number
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.bodyText1.copyWith(
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Lesson Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: AppTextStyles.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (lesson.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lesson.description!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(lesson.duration),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Play Button
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 