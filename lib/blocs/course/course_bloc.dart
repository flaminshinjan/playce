import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import '../../services/supabase_service.dart';

// Events
abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {}

class LoadCourse extends CourseEvent {
  final String courseId;

  const LoadCourse(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class CreateCourse extends CourseEvent {
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? category;

  const CreateCourse({
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.category,
  });

  @override
  List<Object?> get props => [title, description, thumbnailUrl, category];
}

class AddLesson extends CourseEvent {
  final String courseId;
  final String title;
  final String videoUrl;
  final String? description;

  const AddLesson({
    required this.courseId,
    required this.title,
    required this.videoUrl,
    this.description,
  });

  @override
  List<Object?> get props => [courseId, title, videoUrl, description];
}

// States
abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CoursesLoaded extends CourseState {
  final List<CourseModel> courses;

  const CoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseLoaded extends CourseState {
  final CourseModel course;

  const CourseLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final SupabaseService _supabaseService;

  CourseBloc(this._supabaseService) : super(CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<LoadCourse>(_onLoadCourse);
    on<CreateCourse>(_onCreateCourse);
    on<AddLesson>(_onAddLesson);
  }

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    try {
      emit(CourseLoading());
      final courses = await _supabaseService.getCourses();
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onLoadCourse(LoadCourse event, Emitter<CourseState> emit) async {
    try {
      emit(CourseLoading());
      final course = await _supabaseService.getCourseById(event.courseId);
      if (course != null) {
        emit(CourseLoaded(course));
      } else {
        emit(const CourseError('Course not found'));
      }
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onCreateCourse(CreateCourse event, Emitter<CourseState> emit) async {
    try {
      emit(CourseLoading());
      final course = CourseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        description: event.description,
        thumbnailUrl: event.thumbnailUrl,
        category: event.category,
        createdAt: DateTime.now(),
      );
      final createdCourse = await _supabaseService.createCourse(course);
      if (createdCourse != null) {
        final courses = await _supabaseService.getCourses();
        emit(CoursesLoaded(courses));
      } else {
        emit(const CourseError('Failed to create course'));
      }
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onAddLesson(AddLesson event, Emitter<CourseState> emit) async {
    try {
      emit(CourseLoading());
      final lesson = LessonModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courseId: event.courseId,
        title: event.title,
        description: event.description,
        videoUrl: event.videoUrl,
        duration: 0, // This would be calculated from the video
        order: 0, // This will be set by the backend
        createdAt: DateTime.now(),
      );
      final createdLesson = await _supabaseService.addLesson(lesson);
      if (createdLesson != null) {
        final course = await _supabaseService.getCourseById(event.courseId);
        if (course != null) {
          emit(CourseLoaded(course));
        } else {
          emit(const CourseError('Course not found after adding lesson'));
        }
      } else {
        emit(const CourseError('Failed to add lesson'));
      }
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }
} 