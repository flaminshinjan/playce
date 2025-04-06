import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import 'package:pod_player/pod_player.dart';

class LessonCard extends StatelessWidget {
  final LessonModel lesson;

  const LessonCard({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  String? _getYouTubeId() {
    final uri = Uri.parse(lesson.videoUrl);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    }
    return uri.queryParameters['v'];
  }

  void _showVideoPlayer(BuildContext context) {
    final videoId = _getYouTubeId();
    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube URL')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoId: videoId,
          title: lesson.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.play_arrow, color: Colors.white),
        ),
        title: Text(
          lesson.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: lesson.description != null
            ? Text(
                lesson.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: () => _showVideoPlayer(context),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;

  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
    required this.title,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final PodPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube('https://youtu.be/${widget.videoId}'),
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: true,
        isLooping: false,
      ),
    )..initialise();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: PodVideoPlayer(
          controller: _controller,
          videoThumbnail: DecorationImage(
            image: NetworkImage('https://img.youtube.com/vi/${widget.videoId}/maxresdefault.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
} 