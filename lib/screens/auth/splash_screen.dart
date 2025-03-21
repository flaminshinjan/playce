import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playce/blocs/auth/auth_bloc.dart';
import 'package:playce/blocs/auth/auth_state.dart' as app_auth;
import 'package:playce/constants/app_theme.dart';
import 'package:playce/screens/auth/login_screen.dart';
import 'package:playce/screens/auth/create_profile_screen.dart';
import 'package:playce/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return BlocListener<AuthBloc, app_auth.AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated && !state.needsProfile) {
          // User is authenticated and has a profile, go to home screen
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
          );
          
          // Navigate to home screen
          Future.delayed(const Duration(milliseconds: 500), () {
            // Close loading dialog if it's open
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          });
        } else if (state.isAuthenticated && state.needsProfile || 
                  state.status == app_auth.AuthStatus.profileCreationRequired) {
          // User is authenticated but needs to create a profile
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
          );
          
          // Navigate to profile creation screen
          Future.delayed(const Duration(milliseconds: 500), () {
            // Close loading dialog if it's open
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
            );
          });
        } else if (state.status == app_auth.AuthStatus.unauthenticated) {
          // User is not authenticated, go to login screen
          // Show loading indicator 
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
          );
          
          // Navigate to login screen
          Future.delayed(const Duration(milliseconds: 500), () {
            // Close loading dialog if it's open
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          });
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Stack(
            children: [
              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // App logo
                            Image.asset(
                              'assets/images/logo.png',
                              width: 200,
                              color: Colors.yellow,
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Loading spinner
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.yellow.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Version text at bottom
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.yellow.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 