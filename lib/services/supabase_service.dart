import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playce/constants/supabase_constants.dart';
import 'package:playce/models/message_model.dart';
import 'package:playce/models/user_model.dart';
import 'package:playce/models/post_model.dart';
import 'package:playce/models/comment_model.dart';
import 'package:playce/models/course_model.dart';
import 'package:playce/models/lesson_model.dart';
import 'package:playce/utils/supabase_logger.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service class to handle all Supabase operations
class SupabaseService {
  final _supabaseClient = Supabase.instance.client;
  final _logger = SupabaseLogger();
  
  /// Initialize Supabase client
  static Future<void> initialize() async {
    final logger = SupabaseLogger();
    try {
      logger.i('SUPABASE_INIT', 'Initializing Supabase client');
      
      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        anonKey: SupabaseConstants.supabaseAnonKey,
      );
      
      logger.i('SUPABASE_INIT', 'Supabase client initialized successfully');
    } catch (e, stackTrace) {
      logger.e('SUPABASE_INIT', 'Failed to initialize Supabase client', e, stackTrace);
      rethrow;
    }
  }
  
  // Authentication methods
  bool isAuthenticated() {
    return _supabaseClient.auth.currentUser != null;
  }
  
  String? getCurrentUserId() {
    return _supabaseClient.auth.currentUser?.id;
  }
  
  Future<UserModel?> getCurrentUser() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    
    try {
      final data = await _supabaseClient
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(data);
    } catch (e) {
      _logger.e('GET_CURRENT_USER', 'Error fetching current user', e);
      return null;
    }
  }
  
  Future<AuthResponse> signIn({required String email, required String password}) async {
    try {
      _logger.i('SIGN_IN', 'Attempting sign in with email: $email');
      
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      _logger.i('SIGN_IN', 'User signed in successfully: ${response.user?.id}');
      return response;
    } catch (e) {
      _logger.e('SIGN_IN', 'Sign in failed', e);
      rethrow;
    }
  }
  
  Future<AuthResponse> signUp({required String email, required String password}) async {
    try {
      _logger.i('SIGN_UP', 'Attempting sign up with email: $email');
      
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      
      _logger.i('SIGN_UP', 'User signed up successfully: ${response.user?.id}');
      return response;
    } catch (e) {
      _logger.e('SIGN_UP', 'Sign up failed', e);
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      _logger.i('SIGN_OUT', 'Signing out user');
      await _supabaseClient.auth.signOut();
      _logger.i('SIGN_OUT', 'User signed out successfully');
    } catch (e) {
      _logger.e('SIGN_OUT', 'Sign out failed', e);
      rethrow;
    }
  }
  
  // User methods
  Future<UserModel?> createUserProfile(UserModel user) async {
    try {
      _logger.i('CREATE_USER_PROFILE', 'Creating user profile for: ${user.id}');
      
      await _supabaseClient
          .from(SupabaseConstants.usersTable)
          .insert(user.toJson());
      
      return user;
    } catch (e) {
      _logger.e('CREATE_USER_PROFILE', 'Error creating user profile', e);
      rethrow;
    }
  }
  
  Future<UserModel?> updateUserProfile(UserModel user) async {
    try {
      _logger.i('UPDATE_USER_PROFILE', 'Updating user profile for: ${user.id}');
      
      await _supabaseClient
          .from(SupabaseConstants.usersTable)
          .update(user.toJson())
          .eq('id', user.id);
      
      return user;
    } catch (e) {
      _logger.e('UPDATE_USER_PROFILE', 'Error updating user profile', e);
      rethrow;
    }
  }

  Future<String> uploadImage(File imageFile, String bucket) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = '${const Uuid().v4()}$fileExt';
      final filePath = '$bucket/$fileName';
      
      _logger.i('UPLOAD_IMAGE', 'Uploading image to: $filePath');
      
      await _supabaseClient.storage
          .from(bucket)
          .upload(fileName, imageFile);
      
      final imageUrl = _supabaseClient.storage
          .from(bucket)
          .getPublicUrl(fileName);
      
      _logger.i('UPLOAD_IMAGE', 'Image uploaded successfully: $imageUrl');
      
      return imageUrl;
    } catch (e) {
      _logger.e('UPLOAD_IMAGE', 'Error uploading image', e);
      rethrow;
    }
  }
  
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabaseClient
          .from(SupabaseConstants.usersTable)
          .select()
          .order('username');
      
      return (response as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      _logger.e('GET_ALL_USERS', 'Error fetching users', e);
      return [];
    }
  }
  
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await _supabaseClient
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(data);
    } catch (e) {
      _logger.e('GET_USER_PROFILE', 'Error fetching user profile', e);
      return null;
    }
  }
  
  // Post methods
  Future<void> createPost(PostModel post) async {
    try {
      _logger.i('CREATE_POST', 'Creating post with id: ${post.id}');
      
      await _supabaseClient
          .from(SupabaseConstants.postsTable)
          .insert(post.toJson());
      
      _logger.i('CREATE_POST', 'Post created successfully');
    } catch (e) {
      _logger.e('CREATE_POST', 'Error creating post', e);
      rethrow;
    }
  }
  
  Future<List<PostModel>> getFeedPosts() async {
    try {
      final response = await _supabaseClient
          .from(SupabaseConstants.postsTable)
          .select('*, ${SupabaseConstants.usersTable}(username, avatar_url)')
          .order('created_at', ascending: false);
      
      return (response as List).map((post) => PostModel.fromJson(post)).toList();
    } catch (e) {
      _logger.e('GET_FEED_POSTS', 'Error fetching feed posts', e);
      return [];
    }
  }
  
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final response = await _supabaseClient
          .from(SupabaseConstants.postsTable)
          .select('*, ${SupabaseConstants.usersTable}(username, avatar_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((post) => PostModel.fromJson(post)).toList();
    } catch (e) {
      _logger.e('GET_USER_POSTS', 'Error fetching user posts', e);
      return [];
    }
  }
  
  // Like methods
  Future<void> likePost(String postId, String userId) async {
    try {
      await _supabaseClient
          .from(SupabaseConstants.likesTable)
          .insert({
            'post_id': postId,
            'user_id': userId,
          });
    } catch (e) {
      _logger.e('LIKE_POST', 'Error liking post', e);
      throw e;
    }
  }
  
  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _supabaseClient
          .from(SupabaseConstants.likesTable)
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } catch (e) {
      _logger.e('UNLIKE_POST', 'Error unliking post', e);
      throw e;
    }
  }
  
  // Message methods
  Future<List<MessageModel>> getMessages(String senderId, String receiverId) async {
    try {
      _logger.i('GET_MESSAGES', 'Fetching messages between $senderId and $receiverId');
      
      // Use a simpler query format to avoid relationship issues
      final response = await _supabaseClient
          .from(SupabaseConstants.messagesTable)
          .select()
          .or('and(sender_id.eq.$senderId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$senderId)')
          .order('created_at', ascending: true);
      
      _logger.i('GET_MESSAGES', 'Retrieved ${(response as List).length} messages');
      
      // Get user profiles separately to avoid join relationship issues
      final senderProfile = await getUserProfile(senderId);
      final receiverProfile = await getUserProfile(receiverId);
      
      // Map of user IDs to their profiles
      final userProfiles = {
        senderId: senderProfile,
        receiverId: receiverProfile,
      };
      
      // Process messages to add sender info
      return response.map((message) {
        // Get the sender profile
        final messageSenderId = message['sender_id'];
        final senderProfile = userProfiles[messageSenderId];
        
        // Add sender info to the message manually
        if (senderProfile != null) {
          message['sender_username'] = senderProfile.username;
          message['sender_avatar_url'] = senderProfile.avatarUrl;
        }
        
        return MessageModel.fromJson(message);
      }).toList();
    } catch (e) {
      _logger.e('GET_MESSAGES', 'Error fetching messages', e);
      throw e;
    }
  }
  
  Future<void> sendMessage(MessageModel message) async {
    try {
      // Create a message with a valid UUID if one isn't already provided
      final messageToSend = message.id.isEmpty 
          ? message.copyWith(id: const Uuid().v4()) 
          : message;
      
      _logger.i('SEND_MESSAGE', 'Sending message with ID: ${messageToSend.id}');
      
      // Only include necessary fields to avoid any potential errors
      final messageData = {
        'id': messageToSend.id,
        'sender_id': messageToSend.senderId,
        'receiver_id': messageToSend.receiverId,
        'content': messageToSend.content,
        'created_at': messageToSend.createdAt.toIso8601String(),
        'is_read': messageToSend.isRead,
      };
      
      await _supabaseClient
          .from(SupabaseConstants.messagesTable)
          .insert(messageData);
          
      _logger.i('SEND_MESSAGE', 'Message sent successfully');
    } catch (e) {
      _logger.e('SEND_MESSAGE', 'Error sending message', e);
      throw e;
    }
  }
  
  Future<void> markMessagesAsRead(String senderId, String receiverId) async {
    try {
      await _supabaseClient
          .from(SupabaseConstants.messagesTable)
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId)
          .eq('is_read', false);
    } catch (e) {
      _logger.e('MARK_MESSAGES_READ', 'Error marking messages as read', e);
      throw e;
    }
  }
  
  RealtimeChannel getMessagesSubscription(String chatId) {
    // Create a unique channel name based on the chat ID
    final channelName = 'messages_channel_$chatId';
    
    return _supabaseClient
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.messagesTable,
          callback: (payload) {
            _logger.i('REALTIME_EVENT', 'Received message notification', payload.newRecord);
          },
        )
        .subscribe((status, error) {
          if (status == 'SUBSCRIBED') {
            _logger.i('REALTIME_EVENT', 'Successfully subscribed to messages channel: $channelName');
          } else if (error != null) {
            _logger.e('REALTIME_EVENT', 'Failed to subscribe to messages channel', error);
          }
        });
  }
  
  // Comment methods
  Future<List<CommentModel>> getPostComments(String postId) async {
    try {
      final response = await _supabaseClient
          .from(SupabaseConstants.commentsTable)
          .select('*, ${SupabaseConstants.usersTable}(username, avatar_url)')
          .eq('post_id', postId)
          .order('created_at');
      
      return (response as List).map((comment) => CommentModel.fromJson(comment)).toList();
    } catch (e) {
      _logger.e('GET_POST_COMMENTS', 'Error fetching post comments', e);
      return [];
    }
  }
  
  Future<CommentModel> addComment(String postId, String content) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get user profile for username
      final userProfile = await getUserProfile(userId);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }
      
      final comment = CommentModel(
        id: const Uuid().v4(),
        postId: postId,
        userId: userId,
        username: userProfile.username ?? 'Anonymous',
        userAvatarUrl: userProfile.avatarUrl,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _supabaseClient
          .from(SupabaseConstants.commentsTable)
          .insert(comment.toJson());
      
      return comment;
    } catch (e) {
      _logger.e('ADD_COMMENT', 'Error adding comment', e);
      rethrow;
    }
  }
  
  Future<bool> deleteComment(String commentId) async {
    try {
      await _supabaseClient
          .from(SupabaseConstants.commentsTable)
          .delete()
          .eq('id', commentId);
      
      return true;
    } catch (e) {
      _logger.e('DELETE_COMMENT', 'Error deleting comment', e);
      rethrow;
    }
  }
  
  // Course methods
  Future<List<CourseModel>> getCourses() async {
    try {
      _logger.i('GET_COURSES', 'Fetching courses');
      
      final data = await _supabaseClient
          .from(SupabaseConstants.coursesTable)
          .select()
          .order('created_at', ascending: false);
      
      final courses = data.map<CourseModel>((json) => CourseModel.fromJson(json)).toList();
      
      _logger.i('GET_COURSES', 'Fetched ${courses.length} courses');
      return courses;
    } catch (e) {
      _logger.e('GET_COURSES', 'Error fetching courses', e);
      rethrow;
    }
  }
  
  Future<CourseModel> getCourseById(String courseId) async {
    try {
      _logger.i('GET_COURSE_BY_ID', 'Fetching course: $courseId');
      
      final data = await _supabaseClient
          .from(SupabaseConstants.coursesTable)
          .select()
          .eq('id', courseId)
          .single();
      
      final courseData = CourseModel.fromJson(data);
      
      // Fetch lessons for this course
      final lessonsData = await _supabaseClient
          .from(SupabaseConstants.lessonsTable)
          .select()
          .eq('course_id', courseId)
          .order('order', ascending: true);
      
      final lessons = lessonsData.map<LessonModel>((json) => LessonModel.fromJson(json)).toList();
      
      _logger.i('GET_COURSE_BY_ID', 'Fetched course with ${lessons.length} lessons');
      return courseData.copyWith(lessons: lessons, totalLessons: lessons.length);
    } catch (e) {
      _logger.e('GET_COURSE_BY_ID', 'Error fetching course by id', e);
      rethrow;
    }
  }
  
  Future<CourseModel> createCourse(CourseModel course) async {
    try {
      _logger.i('CREATE_COURSE', 'Creating new course: ${course.title}');
      
      final data = await _supabaseClient
          .from(SupabaseConstants.coursesTable)
          .insert(course.toJson())
          .select()
          .single();
      
      _logger.i('CREATE_COURSE', 'Created course with id: ${data['id']}');
      return CourseModel.fromJson(data);
    } catch (e) {
      _logger.e('CREATE_COURSE', 'Error creating course', e);
      rethrow;
    }
  }
  
  Future<LessonModel> createLesson(LessonModel lesson) async {
    try {
      _logger.i('CREATE_LESSON', 'Creating new lesson: ${lesson.title}');
      
      final data = await _supabaseClient
          .from(SupabaseConstants.lessonsTable)
          .insert(lesson.toJson())
          .select()
          .single();
      
      _logger.i('CREATE_LESSON', 'Created lesson with id: ${data['id']}');
      return LessonModel.fromJson(data);
    } catch (e) {
      _logger.e('CREATE_LESSON', 'Error creating lesson', e);
      rethrow;
    }
  }
  
  Future<LessonModel> getLessonById(String lessonId) async {
    try {
      _logger.i('GET_LESSON_BY_ID', 'Fetching lesson: $lessonId');
      
      final data = await _supabaseClient
          .from(SupabaseConstants.lessonsTable)
          .select()
          .eq('id', lessonId)
          .single();
      
      _logger.i('GET_LESSON_BY_ID', 'Fetched lesson: ${data['title']}');
      return LessonModel.fromJson(data);
    } catch (e) {
      _logger.e('GET_LESSON_BY_ID', 'Error fetching lesson by id', e);
      rethrow;
    }
  }
  
  Future<String> uploadCourseImage(File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'course_${const Uuid().v4()}$fileExt';
      
      _logger.i('UPLOAD_COURSE_IMAGE', 'Uploading course image: $fileName');
      
      await _supabaseClient.storage
          .from(SupabaseConstants.courseImagesBucket)
          .upload(fileName, imageFile);
      
      final imageUrl = _supabaseClient.storage
          .from(SupabaseConstants.courseImagesBucket)
          .getPublicUrl(fileName);
      
      _logger.i('UPLOAD_COURSE_IMAGE', 'Course image uploaded successfully');
      return imageUrl;
    } catch (e) {
      _logger.e('UPLOAD_COURSE_IMAGE', 'Error uploading course image', e);
      rethrow;
    }
  }
  
  Future<String> uploadCourseVideo(File videoFile) async {
    try {
      final fileExt = path.extension(videoFile.path);
      final fileName = 'lesson_${const Uuid().v4()}$fileExt';
      
      _logger.i('UPLOAD_COURSE_VIDEO', 'Uploading course video: $fileName');
      
      await _supabaseClient.storage
          .from('course-videos')
          .upload(fileName, videoFile);
      
      final videoUrl = _supabaseClient.storage
          .from('course-videos')
          .getPublicUrl(fileName);
      
      _logger.i('UPLOAD_COURSE_VIDEO', 'Course video uploaded successfully');
      return videoUrl;
    } catch (e) {
      _logger.e('UPLOAD_COURSE_VIDEO', 'Error uploading course video', e);
      rethrow;
    }
  }
  
  Future<void> updateLessonProgress(String lessonId, bool isCompleted) async {
    final userId = getCurrentUserId();
    if (userId == null) return;
    
    try {
      _logger.i('UPDATE_LESSON_PROGRESS', 'Updating lesson progress: $lessonId');
      
      final existingProgress = await _supabaseClient
          .from(SupabaseConstants.progressTable)
          .select()
          .eq('user_id', userId)
          .eq('lesson_id', lessonId);
      
      if (existingProgress.isEmpty) {
        await _supabaseClient
            .from(SupabaseConstants.progressTable)
            .insert({
              'user_id': userId,
              'lesson_id': lessonId,
              'is_completed': isCompleted,
              'last_watched_at': DateTime.now().toIso8601String(),
            });
      } else {
        await _supabaseClient
            .from(SupabaseConstants.progressTable)
            .update({
              'is_completed': isCompleted,
              'last_watched_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('lesson_id', lessonId);
      }
      
      _logger.i('UPDATE_LESSON_PROGRESS', 'Lesson progress updated');
    } catch (e) {
      _logger.e('UPDATE_LESSON_PROGRESS', 'Error updating lesson progress', e);
      rethrow;
    }
  }
} 