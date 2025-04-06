-- Insert the Flutter course
INSERT INTO courses (id, title, description, thumbnail_url, category, created_at)
VALUES (
  '1',
  'Flutter Development Masterclass',
  'Learn Flutter from scratch and build beautiful, responsive mobile applications',
  'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png',
  'Mobile Development',
  NOW()
);

-- Insert lessons for the Flutter course
INSERT INTO lessons (id, course_id, title, description, video_url, duration, "order", created_at)
VALUES
  (
    '1',
    '1',
    'Introduction to Flutter',
    'Get started with Flutter and understand the basics of the framework',
    'https://www.youtube.com/watch?v=fq4N0hgOWzU',
    3600, -- 1 hour in seconds
    1,
    NOW()
  ),
  (
    '2',
    '1',
    'Building Your First Flutter App',
    'Create your first Flutter application and learn about widgets',
    'https://www.youtube.com/watch?v=1ukSR1GRtMU',
    4800, -- 1 hour and 20 minutes in seconds
    2,
    NOW()
  ),
  (
    '3',
    '1',
    'State Management in Flutter',
    'Learn about different state management approaches in Flutter',
    'https://www.youtube.com/watch?v=3tm-R7ymwhc',
    5400, -- 1 hour and 30 minutes in seconds
    3,
    NOW()
  ); 