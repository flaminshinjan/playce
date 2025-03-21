# Playce Documentation

## Table of Contents
- [Course Module](#course-module)
- [Supabase Setup](#supabase-setup)
- [Video Upload Guidelines](#video-upload-guidelines)

## Course Module

The courses module allows users to browse and watch video-based courses. Each course consists of multiple video lessons with descriptions. Users can track their progress through courses as they watch lessons.

### Course Data Structure

Courses are organized as follows:
- **Course**: A collection of lessons with a title, description, thumbnail, and category
- **Lesson**: An individual video with a title, description, and duration

## Supabase Setup

### Storage Buckets Setup

1. Navigate to the Storage section in the Supabase dashboard
2. Create two buckets:
   - `course-images` - For course thumbnails
   - `course-videos` - For video lessons

### Bucket Permissions

For each bucket:
1. Go to "Configuration" -> "Policies"
2. Ensure there's a policy that allows authenticated users to read files
3. Add a policy that allows certain roles to upload files (for admin users)

### Database Tables

The application requires the following tables:

1. **`courses`**:
   - `id` (primary key)
   - `title` - Course title
   - `description` - Course description
   - `thumbnail_url` - URL to the uploaded thumbnail
   - `category` - Course category
   - `created_at` - Timestamp

2. **`lessons`**:
   - `id` (primary key)
   - `course_id` (foreign key) - ID of the parent course
   - `title` - Lesson title
   - `description` - Lesson description
   - `video_url` - URL to the uploaded video
   - `duration` - Video duration in seconds
   - `order` - Sequence number for ordering lessons
   - `created_at` - Timestamp

## Video Upload Guidelines

### Uploading Content

1. **Upload Course Thumbnails**:
   - Use the Supabase dashboard to manually upload images to `course-images` bucket
   - Supported formats: JPG, PNG, WebP

2. **Upload Video Files**:
   - Upload MP4 files to the `course-videos` bucket
   - Note the URL path of each uploaded video

### Technical Requirements

- **Maximum File Size**: 50MB per file in the free tier
- **Supported Formats**: MP4 with H.264 encoding
- **Resolution**: 720p (1280x720) or 1080p (1920x1080)
- **Duration**: 5-15 minutes per lesson is recommended
- **Quality**: Use proper lighting and clear audio 