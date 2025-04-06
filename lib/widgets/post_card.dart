import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header with user info
            Padding(
              padding: EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                top: 12.0,
                bottom: post.imageUrl == null ? 4.0 : 12.0, // Less bottom padding for text-only posts
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20, // Slightly smaller avatar for text-only posts
                    backgroundImage: NetworkImage(post.userAvatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: AppTextStyles.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeago.format(post.createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    padding: EdgeInsets.zero, // Remove padding from icon button
                    constraints: const BoxConstraints(), // Remove constraints
                    onPressed: () {
                      // Show post options
                    },
                  ),
                ],
              ),
            ),
            
            // Post Caption
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: post.imageUrl == null ? 4.0 : 8.0, // Less vertical padding for text-only posts
              ),
              child: Text(
                post.caption,
                style: AppTextStyles.bodyText1,
              ),
            ),
            
            // Post Image - Only show if image URL exists
            if (post.imageUrl != null)
              AspectRatio(
                aspectRatio: 1.0,
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text('Failed to load image'),
                      ),
                    );
                  },
                ),
              ),
            
            // Post Actions
            Padding(
              padding: EdgeInsets.all(post.imageUrl == null ? 8.0 : 12.0), // Less padding for text-only posts
              child: Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: post.isLiked ? Colors.red : AppColors.textSecondary,
                          size: post.imageUrl == null ? 20 : 24, // Smaller icons for text-only posts
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onLike,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.likeCount.toString(),
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.comment_outlined,
                          size: post.imageUrl == null ? 20 : 24, // Smaller icons for text-only posts
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onComment,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.commentCount.toString(),
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 