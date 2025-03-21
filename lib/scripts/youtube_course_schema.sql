-- Create courses table if it doesn't exist
CREATE TABLE IF NOT EXISTS courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  thumbnail_url TEXT,
  total_lessons INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create lessons table if it doesn't exist
CREATE TABLE IF NOT EXISTS lessons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT NOT NULL,
  duration INT, -- Duration in seconds
  "order" INT NOT NULL, -- Order in the course (using "order" instead of sequence_number)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add index for faster querying
CREATE INDEX IF NOT EXISTS idx_lessons_course_id ON lessons(course_id);

-- Sample course data
INSERT INTO courses (id, title, description, category, thumbnail_url, total_lessons)
VALUES (
  '12345678-1234-1234-1234-123456789abc', -- Using a fixed UUID for easy reference
  'Getting Started with Flutter',
  'Learn the basics of Flutter development and build your first app. This course covers Flutter installation, widgets, layouts, navigation, and more.',
  'Programming',
  'https://i.ytimg.com/vi/x0uinJvhNxI/maxresdefault.jpg',
  3
);

-- Sample lessons for Flutter course
INSERT INTO lessons (course_id, title, description, video_url, duration, "order")
VALUES
  (
    '12345678-1234-1234-1234-123456789abc',
    'Introduction to Flutter',
    'Get to know what Flutter is and why it's awesome for building cross-platform apps.',
    'https://www.youtube.com/watch?v=fq4N0hgOWzU',
    423, -- 7:03 minutes
    1
  ),
  (
    '12345678-1234-1234-1234-123456789abc',
    'Setting Up Your Development Environment',
    'Install Flutter SDK, set up your IDE, and run your first app.',
    'https://www.youtube.com/watch?v=Z2ugnpCQuyw',
    985, -- 16:25 minutes
    2
  ),
  (
    '12345678-1234-1234-1234-123456789abc',
    'Building Your First Flutter App',
    'Create a simple app with interactive elements and learn about stateful widgets.',
    'https://www.youtube.com/watch?v=1gDhl4leEzA',
    1247, -- 20:47 minutes
    3
  );

-- Add another course for variety
INSERT INTO courses (title, description, category, thumbnail_url, total_lessons)
VALUES (
  'Science for Kids: Fun Experiments',
  'Exciting science experiments that kids can do at home with simple household items. Learn scientific principles through hands-on activities.',
  'Science',
  'https://i.ytimg.com/vi/4MHn9Mj_sas/maxresdefault.jpg',
  2
);

-- Get the ID of the second course
DO $$
DECLARE
  science_course_id UUID;
BEGIN
  SELECT id INTO science_course_id FROM courses WHERE title = 'Science for Kids: Fun Experiments';

  -- Add lessons to the science course
  INSERT INTO lessons (course_id, title, description, video_url, duration, "order")
  VALUES
    (
      science_course_id,
      'Making a Volcano Erupt',
      'Create a chemical reaction to simulate a volcanic eruption.',
      'https://www.youtube.com/watch?v=9b_gltKtERY',
      365, -- 6:05 minutes
      1
    ),
    (
      science_course_id,
      'Rainbow in a Jar',
      'Learn about density by creating a rainbow of colors in a single jar.',
      'https://www.youtube.com/watch?v=sQAf0xngb2k',
      425, -- 7:05 minutes
      2
    );
END $$; 