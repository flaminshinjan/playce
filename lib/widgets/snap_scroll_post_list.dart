import 'package:flutter/material.dart';
import 'package:playce/models/post_model.dart';
import 'package:playce/widgets/post_card.dart';

class SnapScrollPostList extends StatefulWidget {
  final List<PostModel> posts;
  final Function(PostModel) onLike;
  final Function(PostModel) onComment;
  final Function(PostModel) onTap;
  final VoidCallback? onRefresh;

  const SnapScrollPostList({
    Key? key,
    required this.posts,
    required this.onLike,
    required this.onComment,
    required this.onTap,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<SnapScrollPostList> createState() => _SnapScrollPostListState();
}

class _SnapScrollPostListState extends State<SnapScrollPostList> {
  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding to avoid overflow with navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 87; // 75 for navbar + 12 for margin

    if (widget.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.post_add,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to share something!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (widget.onRefresh != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: widget.onRefresh,
                  child: const Text('Refresh'),
                ),
              ),
          ],
        ),
      );
    }

    // Simple ListView with no snapping or special scrolling effects
    return ListView.builder(
      padding: EdgeInsets.only(top: 0, bottom: bottomPadding),
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: PostCard(
            post: widget.posts[index],
            onLike: () => widget.onLike(widget.posts[index]),
            onComment: () => widget.onComment(widget.posts[index]),
            onTap: () => widget.onTap(widget.posts[index]),
          ),
        );
      },
    );
  }
} 