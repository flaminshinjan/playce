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
    // Calculate the height as 70% of the screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.78;
    
    return SizedBox(
      height: cardHeight,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Header with user info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
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
                      onPressed: () {
                        // Show post options
                      },
                    ),
                  ],
                ),
              ),
              
              // Post Caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  post.caption,
                  style: AppTextStyles.bodyText1,
                ),
              ),
              
              // Post Image - Make it flexible to fill available space
              if (post.imageUrl != null)
                Expanded(
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
                )
              else
                const Spacer(), // If no image, add a spacer
              
              // Post Actions
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            post.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: post.isLiked ? Colors.red : AppColors.textSecondary,
                          ),
                          onPressed: onLike,
                        ),
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
                          icon: const Icon(Icons.comment_outlined),
                          onPressed: onComment,
                        ),
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
      ),
    );
  }
} 