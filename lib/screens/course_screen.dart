import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';
import '../widgets/course_card.dart';
import '../widgets/lesson_card.dart';
import '../blocs/course/course_bloc.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({Key? key}) : super(key: key);

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final CourseRepository _courseRepository = CourseRepository();
  late Future<List<CourseModel>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _courseRepository.getCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCourseDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<CourseModel>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const Center(child: Text('No courses available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return CourseCard(
                course: course,
                onTap: () => _showCourseDetails(context, course),
                onAddLesson: () => _showAddLessonDialog(context, course.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddCourseDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final thumbnailController = TextEditingController();
    final categoryController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: thumbnailController,
                decoration: const InputDecoration(labelText: 'Thumbnail URL'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await _courseRepository.createCourse(
                  titleController.text,
                  descriptionController.text,
                  thumbnailController.text,
                  categoryController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {
                    _coursesFuture = _courseRepository.getCourses();
                  });
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddLessonDialog(BuildContext context, String courseId) async {
    final titleController = TextEditingController();
    final videoUrlController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Lesson'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube URL',
                  hintText: 'https://youtube.com/watch?v=...',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && videoUrlController.text.isNotEmpty) {
                await _courseRepository.addLesson(
                  courseId,
                  titleController.text,
                  videoUrlController.text,
                  description: descriptionController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {
                    _coursesFuture = _courseRepository.getCourses();
                  });
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(BuildContext context, CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(course: course),
      ),
    );
  }
}

class CourseDetailsScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailsScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (course.thumbnailUrl != null)
            Image.network(
              course.thumbnailUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          const SizedBox(height: 16),
          Text(
            course.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (course.description != null) ...[
            const SizedBox(height: 8),
            Text(course.description!),
          ],
          const SizedBox(height: 16),
          Text(
            'Lessons',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (course.lessons?.isEmpty ?? true)
            const Center(child: Text('No lessons available'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: course.lessons!.length,
              itemBuilder: (context, index) {
                final lesson = course.lessons![index];
                return LessonCard(lesson: lesson);
              },
            ),
        ],
      ),
    );
  }
} 