import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/lesson_model.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final LessonModel lesson;
  final bool isLastLesson;

  const LessonScreen({
    Key? key,
    required this.courseId,
    required this.lesson,
    this.isLastLesson = false,
  }) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  String? _extractYouTubeId(String url) {
    // Try standard YouTube URL format
    RegExp regExp1 = RegExp(
      r'^https:\/\/(?:www\.|)youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)',
      caseSensitive: false,
    );
    
    // Try shortened youtu.be format
    RegExp regExp2 = RegExp(
      r'^https:\/\/(?:www\.|)youtu\.be\/([a-zA-Z0-9_-]+)',
      caseSensitive: false,
    );
    
    var match = regExp1.firstMatch(url) ?? regExp2.firstMatch(url);
    return match?.group(1);
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl = widget.lesson.videoUrl;
      final youtubeId = _extractYouTubeId(videoUrl);
      
      if (youtubeId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            showLiveFullscreenButton: false,
          ),
        );
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
        return;
      }

      // If not a YouTube URL, try as direct video URL
      _videoController = VideoPlayerController.network(videoUrl);
      await _videoController?.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading video',
                style: AppTextStyles.bodyText1.copyWith(
                  color: Colors.white,
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _initializeVideo,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
        ),
        onReady: () {
          setState(() {
            _isInitialized = true;
          });
        },
      );
    }

    if (_videoController != null) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_videoController!),
          _buildVideoControls(),
        ],
      );
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'No video available',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    if (_videoController == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.5),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _videoController!.value.isPlaying
                    ? _videoController!.pause()
                    : _videoController!.play();
              });
            },
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_videoController!.value.position),
            style: const TextStyle(color: Colors.white),
          ),
          Expanded(
            child: Slider(
              value: _videoController!.value.position.inSeconds.toDouble(),
              min: 0.0,
              max: _videoController!.value.duration.inSeconds.toDouble(),
              onChanged: (value) {
                _videoController!.seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Text(
            _formatDuration(_videoController!.value.duration),
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: Icon(
              _videoController!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _videoController!.setVolume(_videoController!.value.volume > 0 ? 0 : 1);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildVideoPlayer(),
          ),

          // Lesson Info
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.title,
                    style: AppTextStyles.headline2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${(widget.lesson.duration / 60).ceil()} min",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.description ?? 'No description available',
                    style: AppTextStyles.bodyText1,
                  ),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                    child: const Text('Back to Course'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isLastLesson ? null : () {
                      // Show loading indicator when moving to next lesson
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Dialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      );
                      
                      // Simulate loading the next lesson
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        // Close loading dialog
                        Navigator.pop(context);
                        
                        // For now, just go back since we don't have next lesson info
                        Navigator.pop(context);
                      });
                    },
                    child: Text(widget.isLastLesson ? 'Complete Course' : 'Next Lesson'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
