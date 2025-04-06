import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playce/blocs/auth/auth_bloc.dart';
import 'package:playce/blocs/auth/auth_event.dart';
import 'package:playce/blocs/auth/auth_state.dart' as app_auth;
import 'package:playce/constants/app_theme.dart';
import 'package:playce/constants/supabase_constants.dart';
import 'package:playce/models/post_model.dart';
import 'package:playce/models/user_model.dart';
import 'package:playce/services/supabase_service.dart';
import 'package:playce/widgets/post_card.dart';
import 'package:playce/widgets/snap_scroll_post_list.dart';
import 'package:playce/screens/posts/create_post_screen.dart';
import 'package:playce/screens/posts/post_comments_screen.dart';
import 'package:playce/screens/chat/chat_list_screen.dart';
import 'package:playce/screens/courses/courses_screen.dart';
import 'package:playce/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const FeedTab(),
      const CoursesTab(),
      const MessagesTab(),
      const ProfileTab(),
    ];
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: CustomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  final _supabaseService = SupabaseService();
  int _unreadCount = 0;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _checkUnreadMessages();
    
    // Set up periodic check for new messages
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkUnreadMessages();
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _checkUnreadMessages() async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId != null) {
        final query = await Supabase.instance.client
          .from(SupabaseConstants.messagesTable)
          .select()
          .eq('receiver_id', userId)
          .eq('is_read', false);
          
        final count = (query as List).length;
        
        if (mounted && count != _unreadCount) {
          setState(() {
            _unreadCount = count;
          });
        }
      }
    } catch (e) {
      print('Error checking unread messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, 'Feed'),
          _buildNavItem(1, Icons.school_outlined, Icons.school, 'Courses'),
          _buildNavItem(2, Icons.chat_bubble_outline, Icons.chat_bubble, 'Messages', _unreadCount),
          _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, [int badgeCount = 0]) {
    final isSelected = widget.currentIndex == index;
    
    return InkWell(
      onTap: () {
        widget.onTap(index);
        if (index == 2 && _unreadCount > 0) {
          setState(() {
            _unreadCount = 0;
          });
        }
      },
      child: SizedBox(
        width: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        key: ValueKey(isSelected),
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -6,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final _supabaseService = SupabaseService();
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
      final posts = await _supabaseService.getFeedPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _likePost(PostModel post) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) return;

      // Update UI state immediately
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = post.copyWith(
            isLiked: !post.isLiked,
            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
          );
        }
      });

      // Make API call
      if (post.isLiked) {
        await _supabaseService.unlikePost(post.id, userId);
      } else {
        await _supabaseService.likePost(post.id, userId);
      }
    } catch (e) {
      // Revert UI state on error
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = post;  // Restore original state
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _navigateToCreatePost() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );

    // If post was created successfully, refresh feed
    if (result == true) {
      _loadPosts();
    }
  }

  void _updatePost(PostModel updatedPost) {
    setState(() {
      final index = _posts.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        toolbarHeight: 56, // Minimize the app bar height
        elevation: 0, // Remove shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreatePost,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
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
                        'Error loading posts',
                        style: AppTextStyles.bodyText1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage ?? 'Unknown error',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPosts,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : SnapScrollPostList(
                  posts: _posts,
                  onLike: _likePost,
                  onComment: (post) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostCommentsScreen(
                          post: post,
                          onPostUpdated: _updatePost,
                        ),
                      ),
                    );
                  },
                  onTap: (post) {
                    // TODO: Navigate to post details screen
                  },
                  onRefresh: _loadPosts,
                ),
    );
  }
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding to avoid overflow with navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 87; // 75 for navbar + 12 for margin
    
    return const ChatListScreen();
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _supabaseService = SupabaseService();
  bool _isLoading = true;
  String? _errorMessage;
  UserModel? _userProfile;
  List<PostModel> _userPosts = [];
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get user profile
      final userProfile = await _supabaseService.getUserProfile(userId);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }
      
      // Get user posts
      final userPosts = await _supabaseService.getUserPosts(userId);
      
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _userPosts = userPosts;
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
  
  void _signOut() {
    // Show loading dialog
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
    
    // Sign out using AuthBloc
    context.read<AuthBloc>().add(const AuthSignOutEvent());
    
    // Listen for state changes to navigate after sign out
    final authBloc = context.read<AuthBloc>();
    authBloc.stream.listen((state) {
      if (state.status == app_auth.AuthStatus.unauthenticated) {
        // Close loading dialog if it's open
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        
        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false, // Remove all previous routes
        );
      }
    });
  }
  
  void _updatePost(PostModel updatedPost) {
    setState(() {
      final index = _userPosts.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        _userPosts[index] = updatedPost;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
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
                        'Error loading profile',
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
                        onPressed: _loadUserData,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        
                        // User avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _userProfile?.avatarUrl != null
                              ? NetworkImage(_userProfile!.avatarUrl!)
                              : const NetworkImage('https://via.placeholder.com/100'),
                        ),
                        const SizedBox(height: 20),
                        
                        // User name
                        Text(
                          _userProfile?.fullName ?? 'No Name',
                          style: AppTextStyles.headline2,
                        ),
                        const SizedBox(height: 8),
                        
                        // Username
                        Text(
                          '@${_userProfile?.username ?? 'username'}',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        
                        // Bio if available
                        if (_userProfile?.bio != null && _userProfile!.bio!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 32,
                            ),
                            child: Text(
                              _userProfile!.bio!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyText1,
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Account type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _userProfile?.isParent == true
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _userProfile?.isParent == true
                                ? 'Parent Account'
                                : 'Kid Account',
                            style: AppTextStyles.bodyText2.copyWith(
                              color: _userProfile?.isParent == true
                                  ? AppColors.primary
                                  : AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // User posts header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Posts',
                                style: AppTextStyles.headline3,
                              ),
                              Text(
                                '${_userPosts.length} posts',
                                style: AppTextStyles.bodyText2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // User posts - Showing a condensed version for the profile
                        _userPosts.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                  horizontal: 24,
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.post_add,
                                      color: AppColors.textSecondary,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No posts yet',
                                      style: AppTextStyles.bodyText1,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Share something with the community!',
                                      style: AppTextStyles.caption,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 400, // Fixed height for the post preview section
                                child: SnapScrollPostList(
                                  posts: _userPosts,
                                  onLike: (post) {
                                    // TODO: Add like functionality for profile posts
                                  },
                                  onComment: (post) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PostCommentsScreen(
                                          post: post,
                                          onPostUpdated: _updatePost,
                                        ),
                                      ),
                                    );
                                  },
                                  onTap: (post) {
                                    // TODO: Navigate to post details
                                  },
                                ),
                              ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }
} 