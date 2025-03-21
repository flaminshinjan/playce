import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/user_model.dart';
import 'package:playce/screens/chat/chat_screen.dart';
import 'package:playce/services/supabase_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabaseService = SupabaseService();
  
  List<UserModel> _users = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      // Get all users for now - in a real app, you'd get only users with conversations
      final users = await _supabaseService.getAllUsers();
      
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chats: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      return _buildUserListItem(_users[index]);
                    },
                  ),
                ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your conversations will appear here',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserListItem(UserModel user) {
    // Skip current user
    final currentUserId = _supabaseService.getCurrentUserId();
    if (user.id == currentUserId) {
      return const SizedBox.shrink();
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Text(user.username?.substring(0, 1).toUpperCase() ?? '?')
            : null,
      ),
      title: Text(user.username ?? 'User ${user.id.substring(0, 5)}'),
      subtitle: const Text('Tap to send a message'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(recipient: user),
          ),
        );
      },
    );
  }
} 