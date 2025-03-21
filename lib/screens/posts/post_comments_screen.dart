import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/comment_model.dart';
import 'package:playce/models/post_model.dart';
import 'package:playce/services/supabase_service.dart';

class PostCommentsScreen extends StatefulWidget {
  final PostModel post;
  final Function(PostModel updatedPost)? onPostUpdated;

  const PostCommentsScreen({
    Key? key,
    required this.post,
    this.onPostUpdated,
  }) : super(key: key);

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final _supabaseService = SupabaseService();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  
  late PostModel _updatedPost;
  
  @override
  void initState() {
    super.initState();
    _updatedPost = widget.post;
    _loadComments();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadComments() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      final comments = await _supabaseService.getPostComments(widget.post.id);
      
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }
  
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isSending = true;
    });
    
    try {
      await _supabaseService.addComment(
        widget.post.id, 
        _commentController.text.trim(),
      );
      
      // Clear the text field
      _commentController.clear();
      
      // Update the post's comment count
      setState(() {
        _updatedPost = _updatedPost.incrementCommentCount();
      });
      
      // Notify parent about the updated post
      if (widget.onPostUpdated != null) {
        widget.onPostUpdated!(_updatedPost);
      }
      
      // Refresh comments list
      await _loadComments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
  
  Future<void> _deleteComment(CommentModel comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      final success = await _supabaseService.deleteComment(comment.id);
      
      if (success) {
        // Update the post's comment count
        setState(() {
          _updatedPost = _updatedPost.decrementCommentCount();
        });
        
        // Notify parent about the updated post
        if (widget.onPostUpdated != null) {
          widget.onPostUpdated!(_updatedPost);
        }
        
        // Refresh comments list
        await _loadComments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete comment')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _supabaseService.getCurrentUserId();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading comments',
                              style: AppTextStyles.bodyText1,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadComments,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  color: AppColors.textSecondary,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No comments yet',
                                  style: AppTextStyles.bodyText1,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to comment on this post!',
                                  style: AppTextStyles.caption,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadComments,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _comments.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                final isOwnComment = comment.userId == currentUserId;
                                
                                return CommentItem(
                                  comment: comment,
                                  isOwnComment: isOwnComment,
                                  onDelete: () => _deleteComment(comment),
                                );
                              },
                            ),
                          ),
          ),
          
          // Comment input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a comment';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.send),
                          color: AppColors.primary,
                          onPressed: _addComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final bool isOwnComment;
  final VoidCallback onDelete;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.isOwnComment,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundImage: comment.userAvatarUrl != null
              ? NetworkImage(comment.userAvatarUrl!)
              : const NetworkImage('https://via.placeholder.com/40'),
        ),
        const SizedBox(width: 12),
        
        // Comment content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Username and timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.username,
                          style: AppTextStyles.bodyText2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTimestamp(comment.createdAt),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  
                  // Delete option for own comments
                  if (isOwnComment)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppColors.error,
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Comment text
              Text(
                comment.content,
                style: AppTextStyles.bodyText2,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 