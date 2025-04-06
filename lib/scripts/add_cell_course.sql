-- Insert the course
INSERT INTO courses (title, description, category, thumbnail_url, created_at)
VALUES (
  'Cell: The Basic Unit of Life',
  'Explore the fascinating world of cells, the fundamental building blocks of all living organisms. Learn about cell structure, function, and their vital role in life.',
  'Biology',
  'https://img.youtube.com/vi/8vo59AKzU4Q/hqdefault.jpg',
  NOW()
);

-- Get the course ID
DO $$
DECLARE
  course_id UUID;
BEGIN
  SELECT id INTO course_id FROM courses WHERE title = 'Cell: The Basic Unit of Life' ORDER BY created_at DESC LIMIT 1;

  -- Insert the lessons
  INSERT INTO lessons (course_id, title, description, video_url, duration, "order", created_at)
  VALUES 
  (
    course_id,
    'Introduction to Cells',
    'Learn about the basic structure and components of cells, including the cell membrane, nucleus, and cytoplasm.',
    'https://youtu.be/8vo59AKzU4Q',
    600, -- 10 minutes
    1,
    NOW()
  ),
  (
    course_id,
    'Cell Types and Functions',
    'Discover the different types of cells and their specialized functions in living organisms.',
    'https://youtu.be/t5DvF5OVr1Y',
    600, -- 10 minutes
    2,
    NOW()
  );
END $$; 