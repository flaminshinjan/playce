class SupabaseConstants {
  // Replace these with your actual Supabase URL and anon key from your project dashboard
  static const String supabaseUrl = 'https://pqzwhmwihpxbgujzgcbi.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxendobXdpaHB4Ymd1anpnY2JpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1MjU3ODYsImV4cCI6MjA1ODEwMTc4Nn0.jsShslQqOH8wwd46Ul33S5J-cDhsoXkAnNkAq3_P1nk';

  // Supabase table names - match these with your database table names
  static const String usersTable = 'profiles';
  static const String postsTable = 'posts';
  static const String commentsTable = 'comments';
  static const String likesTable = 'likes';
  static const String messagesTable = 'messages';
  static const String coursesTable = 'courses';
  static const String lessonsTable = 'lessons';
  static const String progressTable = 'user_progress';
  
  // Storage bucket names
  static const String profileImagesBucket = 'profile-images';
  static const String postImagesBucket = 'post-images';
  static const String courseImagesBucket = 'course-images';
} 