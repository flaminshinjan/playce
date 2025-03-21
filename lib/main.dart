import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playce/blocs/auth/auth_bloc.dart';
import 'package:playce/blocs/auth/auth_event.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/services/supabase_service.dart';
import 'package:playce/screens/auth/splash_screen.dart';
import 'package:playce/models/post_model.dart';
import 'package:playce/widgets/post_card.dart';
import 'package:playce/utils/supabase_logger.dart';
import 'package:playce/utils/supabase_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure logging for Supabase operations
  // Set appropriate log level based on build mode
  if (kReleaseMode) {
    // Minimal logging in production
    SupabaseLogger().setLogLevel(SupabaseLogger.ERROR);
  } else if (kProfileMode) {
    // Medium logging in profile mode
    SupabaseLogger().setLogLevel(SupabaseLogger.WARNING);
  } else {
    // Verbose logging in debug mode
    SupabaseLogger().setLogLevel(SupabaseLogger.DEBUG);
    
    // Set up the custom BlocObserver to log bloc events (debug only)
    Bloc.observer = SupabaseBlocObserver();
  }
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        supabaseService: SupabaseService(),
      )..add(const AuthCheckStatusEvent()),
      child: MaterialApp(
        title: 'Playce',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Respect system theme
        home: const SplashScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const FeedTab(),
    const CoursesTab(),
    const MessagesTab(),
    const ProfileTab(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Placeholder tabs
class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Create mock posts
    final List<PostModel> mockPosts = [
      PostModel(
        id: '1',
        userId: 'user1',
        caption: 'Just finished my science project! 🧪 #science #learning',
        imageUrl: 'https://via.placeholder.com/400x300',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 15,
        commentCount: 3,
        username: 'emma_kid',
        userAvatarUrl: 'https://via.placeholder.com/150',
      ),
      PostModel(
        id: '2',
        userId: 'user2',
        caption: 'Had so much fun at the zoo today! 🦁🐘 #animals #funday',
        imageUrl: 'https://via.placeholder.com/400x400',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likeCount: 24,
        commentCount: 7,
        username: 'sam_cool',
        userAvatarUrl: 'https://via.placeholder.com/150',
      ),
      PostModel(
        id: '3',
        userId: 'user3',
        caption: 'Check out my art project for school! What do you think? #art #drawing',
        imageUrl: 'https://via.placeholder.com/400x500',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likeCount: 42,
        commentCount: 12,
        username: 'lily_artist',
        userAvatarUrl: 'https://via.placeholder.com/150',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create post screen
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mockPosts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: mockPosts[index],
            onLike: () {
              // Handle like action
            },
            onComment: () {
              // Handle comment action
            },
            onTap: () {
              // Navigate to post details
            },
          );
        },
      ),
    );
  }
}

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: const Center(
        child: Text('Courses Tab - Educational content will appear here'),
      ),
    );
  }
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: const Center(
        child: Text('Messages Tab - Chats will appear here'),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/100'),
            ),
            const SizedBox(height: 20),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('@johndoe'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Sign out user
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
} 