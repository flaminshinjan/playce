import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/models/post_model.dart';
import 'package:playce/models/user_model.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Post',
          style: AppTextStyles.headline3,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _isUploading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
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
                      'Share',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User info section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          FutureBuilder<UserModel?>(
                            future: _supabaseService.getUserProfile(_supabaseService.getCurrentUserId() ?? ''),
                            builder: (context, snapshot) {
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  snapshot.data?.avatarUrl ?? 'https://via.placeholder.com/40',
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          FutureBuilder<UserModel?>(
                            future: _supabaseService.getUserProfile(_supabaseService.getCurrentUserId() ?? ''),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data?.username ?? 'Anonymous',
                                style: AppTextStyles.bodyText1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Caption field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: _captionController,
                        maxLines: null,
                        maxLength: 500,
                        style: AppTextStyles.bodyText1,
                        decoration: InputDecoration(
                          hintText: 'What would you like to share?',
                          hintStyle: AppTextStyles.bodyText1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        validator: (value) {
                          if ((value == null || value.isEmpty) && _selectedImage == null) {
                            return 'Please enter some text or add an image';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    // Image preview if selected
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Bottom actions bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add to your post',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined),
                    color: AppColors.primary,
                    onPressed: _pickImage,
                    tooltip: 'Choose from gallery',
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    color: AppColors.primary,
                    onPressed: _takePhoto,
                    tooltip: 'Take a photo',
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