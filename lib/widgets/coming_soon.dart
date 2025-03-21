import 'package:flutter/material.dart';
import 'package:playce/constants/app_theme.dart';

class ComingSoonWidget extends StatelessWidget {
  final String title;
  final String message;
  
  const ComingSoonWidget({
    Key? key,
    this.title = 'Coming Soon!',
    this.message = 'We\'re working hard to bring you amazing content. Stay tuned!',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rocket/launch icon with animation
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 100,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            title,
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              style: AppTextStyles.bodyText1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 