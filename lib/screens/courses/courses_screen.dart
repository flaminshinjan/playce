import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/course_model.dart';
import 'package:playce/screens/courses/course_detail_screen.dart';
import 'package:playce/services/supabase_service.dart';
import 'package:playce/widgets/course_card.dart';
import 'package:playce/widgets/coming_soon.dart';

class CoursesTab extends StatefulWidget {
  const CoursesTab({super.key});

  @override
  State<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {
  final _supabaseService = SupabaseService();
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String _searchQuery = '';
  final bool _showComingSoon = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    if (_showComingSoon) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
      final courses = await _supabaseService.getCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _filteredCourses = courses;
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

  void _filterCourses(String query) {
    if (_showComingSoon) return;
    
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCourses = _courses;
      } else {
        _filteredCourses = _courses.where((course) {
          final titleMatch = course.title.toLowerCase().contains(query.toLowerCase());
          final descriptionMatch = course.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final categoryMatch = course.category?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return titleMatch || descriptionMatch || categoryMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Courses',
                    style: AppTextStyles.headline1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expand your skills with our video courses',
                    style: AppTextStyles.bodyText1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            if (!_showComingSoon)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: TextField(
                  onChanged: _filterCourses,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: AppTextStyles.bodyText2,
                ),
              ),
            
            // Courses Grid or Coming Soon message
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _showComingSoon
                      ? const ComingSoonWidget(
                          title: 'Courses Coming Soon!',
                          message: 'We\'re preparing amazing educational content for you. Check back soon for exciting courses and tutorials!',
                        )
                      : _hasError
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Failed to load courses',
                                    style: AppTextStyles.bodyText1,
                                  ),
                                  const SizedBox(height: 8),
                                  if (_errorMessage != null)
                                    Text(
                                      _errorMessage!,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadCourses,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _filteredCourses.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _searchQuery.isEmpty ? Icons.school_outlined : Icons.search_off,
                                        color: AppColors.textSecondary,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isEmpty
                                            ? 'No courses available yet'
                                            : 'No courses match "$_searchQuery"',
                                        style: AppTextStyles.bodyText1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadCourses,
                                  color: AppColors.primary,
                                  child: GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: _filteredCourses.length,
                                    itemBuilder: (context, index) {
                                      final course = _filteredCourses[index];
                                      return CourseCard(
                                        course: course,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CourseDetailScreen(courseId: course.id),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
            ),
          ],
        ),
      ),
    );
  }
} 