import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playce/blocs/auth/auth_bloc.dart';
import 'package:playce/blocs/auth/auth_event.dart';
import 'package:playce/blocs/auth/auth_state.dart';
import 'package:playce/blocs/course/course_bloc.dart';
import 'package:playce/constants/app_theme.dart';
import 'package:playce/screens/courses/courses_screen.dart';
import 'package:playce/screens/auth/splash_screen.dart';
import 'package:playce/screens/auth/login_screen.dart';
import 'package:playce/screens/home/home_screen.dart';
import 'package:playce/models/post_model.dart';
import 'package:playce/widgets/post_card.dart';
import 'package:playce/widgets/course_card.dart';
import 'package:playce/screens/course_screen.dart';
import 'package:playce/utils/supabase_logger.dart';
import 'package:playce/utils/supabase_bloc_observer.dart';
import 'package:playce/services/supabase_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  
  // Initialize InAppWebView
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        supabaseService: SupabaseService(),
      ),
      child: MaterialApp(
        title: 'Playce',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
