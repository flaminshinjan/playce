import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: course.thumbnailUrl != null
                    ? Image.network(
                        course.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.school,
                                size: 48,
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
                            size: 48,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
              ),
            ),
            
            // Course Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.isRecommended)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Recommended',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.buttonText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    course.title,
                    style: AppTextStyles.headline3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (course.description != null)
                    Text(
                      course.description!,
                      style: AppTextStyles.bodyText2.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Lesson count and category
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.totalLessons} ${course.totalLessons == 1 ? 'Lesson' : 'Lessons'}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (course.category != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            course.category!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 