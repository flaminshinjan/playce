import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/post_model.dart';
import 'package:playce/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  final _supabaseService = SupabaseService();
  
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
  
  Future<void> _takePhoto() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
  
  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });
      
      try {
        final userId = _supabaseService.getCurrentUserId();
        if (userId == null) {
          throw Exception('User not authenticated');
        }
        
        // Get current user profile
        final userProfile = await _supabaseService.getUserProfile(userId);
        if (userProfile == null) {
          throw Exception('User profile not found');
        }
        
        String? imageUrl;
        if (_selectedImage != null) {
          // Upload image to storage
          imageUrl = await _supabaseService.uploadImage(
            _selectedImage!,
            'post-images',
          );
        }
        
        // Create post object
        final post = PostModel(
          id: const Uuid().v4(),
          userId: userId,
          username: userProfile.username ?? 'Anonymous',
          userAvatarUrl: userProfile.avatarUrl ?? 'https://via.placeholder.com/150',
          caption: _captionController.text.trim(),
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
          likeCount: 0,
          commentCount: 0,
        );
        
        // Save post to Supabase
        await _supabaseService.createPost(post);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully')),
          );
          Navigator.of(context).pop(true); // Return true as result for refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating post: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }
  
  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _createPost,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Caption field
              TextFormField(
                controller: _captionController,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'What would you like to share?',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if ((value == null || value.isEmpty) && _selectedImage == null) {
                    return 'Please enter some text or add an image';
                  }
                  return null;
                },
              ),
              
              const Divider(),
              
              // Image preview if selected
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // Image picker options
              if (_selectedImage == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 