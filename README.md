# Playce

A social learning platform built with Flutter and Supabase.

## Key Features
- User authentication & profiles
- Social feed with posts & comments
- Direct messaging
- Video-based courses with progress tracking

## Tech Stack
- **Frontend**: Flutter
- **Backend**: Supabase (Auth, Database, Storage)

## Quick Start
```bash
# Clone repository
git clone https://github.com/yourusername/playce.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Course Content
Courses are stored in Supabase with:
- Thumbnails in `course-images` bucket
- Videos in `course-videos` bucket (MP4, H.264, ≤50MB)

## Documentation
For more details on setup, configuration, and content management, refer to our [documentation](docs/README.md).

## License
MIT
