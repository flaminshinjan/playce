import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/lesson_model.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final LessonModel lesson;
  final bool isLastLesson;

  const LessonScreen({
    Key? key,
    required this.courseId,
    required this.lesson,
    this.isLastLesson = false,
  }) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  
  // Simulate loading a video
  Future<void> _loadVideo() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
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
  void initState() {
    super.initState();
    _loadVideo();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Loading video content...", style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading video',
                        style: AppTextStyles.bodyText1,
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _loadVideo,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Placeholder
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 72,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Video Player Coming Soon",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Lesson Info
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lesson.title,
                              style: AppTextStyles.headline2,
                            ),
                            const SizedBox(height: 8),
                            if (widget.lesson.duration != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${widget.lesson.duration} min",
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Description',
                              style: AppTextStyles.headline3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.lesson.description ?? 'No description available',
                              style: AppTextStyles.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Navigation Buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                              ),
                              child: const Text('Back to Course'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.isLastLesson ? null : () {
                                // Show loading indicator when moving to next lesson
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Dialog(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                );
                                
                                // Simulate loading the next lesson
                                Future.delayed(const Duration(milliseconds: 1000), () {
                                  // Close loading dialog
                                  Navigator.pop(context);
                                  
                                  // For now, just go back since we don't have next lesson info
                                  Navigator.pop(context);
                                });
                              },
                              child: Text(widget.isLastLesson ? 'Complete Course' : 'Next Lesson'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
