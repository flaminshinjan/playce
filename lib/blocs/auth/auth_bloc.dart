import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playce/blocs/auth/auth_event.dart';
import 'package:playce/blocs/auth/auth_state.dart' as app_auth;
import 'package:playce/models/user_model.dart';
import 'package:playce/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:playce/utils/supabase_logger.dart';
import 'package:playce/constants/supabase_constants.dart';

class AuthBloc extends Bloc<AuthEvent, app_auth.AuthState> {
  final SupabaseService _supabaseService;
  final SupabaseLogger _logger = SupabaseLogger();

  AuthBloc({
    required SupabaseService supabaseService,
  })  : _supabaseService = supabaseService,
        super(app_auth.AuthState.initial()) {
    on<AuthCheckStatusEvent>(_onAuthCheckStatus);
    on<AuthSignInEvent>(_onAuthSignIn);
    on<AuthSignUpEvent>(_onAuthSignUp);
    on<AuthCreateProfileEvent>(_onAuthCreateProfile);
    on<AuthUpdateProfileEvent>(_onAuthUpdateProfile);
    on<AuthSignOutEvent>(_onAuthSignOut);
    
    _logger.i('AUTH_BLOC', 'AuthBloc initialized');
  }

  Future<void> _onAuthCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    _logger.i('AUTH_CHECK_STATUS', 'Checking authentication status');
    emit(state.copyWith(status: app_auth.AuthStatus.loading));

    try {
      final isAuthenticated = _supabaseService.isAuthenticated();
      _logger.d('AUTH_CHECK_STATUS', 'Authentication check result', {'isAuthenticated': isAuthenticated});

      if (isAuthenticated) {
        final userId = _supabaseService.getCurrentUserId();
        _logger.d('AUTH_CHECK_STATUS', 'User is authenticated', {'userId': userId});
        
        if (userId != null) {
          try {
            final userProfile = await _supabaseService.getUserProfile(userId);

            if (userProfile != null) {
              _logger.i('AUTH_CHECK_STATUS', 'User profile found', {'userId': userId, 'username': userProfile.username});
              emit(state.copyWith(
                status: app_auth.AuthStatus.authenticated,
                user: userProfile,
              ));
            } else {
              _logger.i('AUTH_CHECK_STATUS', 'User authenticated but profile not found', {'userId': userId});
              emit(state.copyWith(
                status: app_auth.AuthStatus.profileCreationRequired,
              ));
            }
          } catch (e) {
            // This will catch the Postgrest error when no profile is found
            _logger.i('AUTH_CHECK_STATUS', 'Error fetching profile, likely needs profile creation', 
                {'userId': userId, 'error': e.toString()});
            
            emit(state.copyWith(
              status: app_auth.AuthStatus.profileCreationRequired,
            ));
          }
        } else {
          _logger.w('AUTH_CHECK_STATUS', 'User is authenticated but no userId found');
          emit(state.copyWith(status: app_auth.AuthStatus.unauthenticated));
        }
      } else {
        _logger.i('AUTH_CHECK_STATUS', 'User is not authenticated');
        emit(state.copyWith(status: app_auth.AuthStatus.unauthenticated));
      }
    } catch (e, stackTrace) {
      _logger.e('AUTH_CHECK_STATUS', 'Error checking auth status', e, stackTrace);
      emit(state.copyWith(
        status: app_auth.AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAuthSignIn(
    AuthSignInEvent event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    _logger.i('AUTH_SIGN_IN', 'Sign in attempt started', {'email': event.email});
    emit(state.copyWith(status: app_auth.AuthStatus.loading));

    try {
      _logger.d('AUTH_SIGN_IN', 'Calling Supabase signIn method');
      final response = await _supabaseService.signIn(
        email: event.email,
        password: event.password,
      );

      final userId = response.user?.id;
      _logger.d('AUTH_SIGN_IN', 'Sign in response received', {
        'success': userId != null,
        'userId': userId,
        'hasSession': response.session != null,
      });
      
      if (userId != null) {
        _logger.d('AUTH_SIGN_IN', 'Fetching user profile', {'userId': userId});
        final userProfile = await _supabaseService.getUserProfile(userId);

        if (userProfile != null) {
          _logger.i('AUTH_SIGN_IN', 'Sign in successful with profile', {
            'userId': userId,
            'username': userProfile.username,
            'isParent': userProfile.isParent,
          });
          
          emit(state.copyWith(
            status: app_auth.AuthStatus.authenticated,
            user: userProfile,
          ));
        } else {
          _logger.i('AUTH_SIGN_IN', 'Sign in successful but profile needed', {'userId': userId});
          
          emit(state.copyWith(
            status: app_auth.AuthStatus.profileCreationRequired,
          ));
        }
      } else {
        _logger.w('AUTH_SIGN_IN', 'Sign in failed - no user ID returned');
        
        emit(state.copyWith(
          status: app_auth.AuthStatus.error,
          errorMessage: 'Failed to sign in. Please try again.',
        ));
      }
    } catch (e, stackTrace) {
      _logger.e('AUTH_SIGN_IN', 'Sign in error', e, stackTrace);
      
      emit(state.copyWith(
        status: app_auth.AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAuthSignUp(
    AuthSignUpEvent event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    _logger.i('AUTH_SIGN_UP', 'Sign up attempt started', {'email': event.email});
    emit(state.copyWith(status: app_auth.AuthStatus.loading));

    try {
      _logger.d('AUTH_SIGN_UP', 'Calling Supabase signUp method');
      final response = await _supabaseService.signUp(
        email: event.email,
        password: event.password,
      );

      final userId = response.user?.id;
      _logger.d('AUTH_SIGN_UP', 'Sign up response received', {
        'success': userId != null,
        'userId': userId,
        'hasSession': response.session != null,
      });
      
      if (userId != null) {
        _logger.i('AUTH_SIGN_UP', 'Sign up successful, profile creation required', {'userId': userId});
        emit(state.copyWith(
          status: app_auth.AuthStatus.profileCreationRequired,
        ));
      } else {
        _logger.w('AUTH_SIGN_UP', 'Sign up failed - no user ID returned');
        emit(state.copyWith(
          status: app_auth.AuthStatus.error,
          errorMessage: 'Failed to sign up. Please try again.',
        ));
      }
    } catch (e, stackTrace) {
      _logger.e('AUTH_SIGN_UP', 'Sign up error', e, stackTrace);
      emit(state.copyWith(
        status: app_auth.AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAuthCreateProfile(
    AuthCreateProfileEvent event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    _logger.i('AUTH_CREATE_PROFILE', 'Creating user profile', {
      'username': event.username,
      'hasProfileImage': event.profileImage != null
    });
    
    emit(state.copyWith(status: app_auth.AuthStatus.loading));

    try {
      final userId = _supabaseService.getCurrentUserId();
      _logger.d('AUTH_CREATE_PROFILE', 'Got current user ID', {'userId': userId});
      
      if (userId != null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null && user.email != null) {
          _logger.d('AUTH_CREATE_PROFILE', 'Building user profile object', {
            'email': user.email,
            'username': event.username
          });
          
          String? avatarUrl;
          
          // Upload profile image if provided
          if (event.profileImage != null) {
            try {
              _logger.d('AUTH_CREATE_PROFILE', 'Uploading profile image');
              avatarUrl = await _supabaseService.uploadImage(
                event.profileImage!, 
                SupabaseConstants.profileImagesBucket
              );
              _logger.d('AUTH_CREATE_PROFILE', 'Profile image uploaded', {'avatarUrl': avatarUrl});
            } catch (e, stackTrace) {
              _logger.e('AUTH_CREATE_PROFILE', 'Failed to upload profile image', e, stackTrace);
              // Continue without profile image if upload fails
            }
          }
          
          final userProfile = UserModel(
            id: userId,
            email: user.email!,
            username: event.username,
            fullName: event.fullName,
            bio: event.bio,
            isParent: event.isParent,
            avatarUrl: avatarUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            // Don't set childrenIds if user is not a parent
            childrenIds: event.isParent ? [] : null,
          );

          _logger.d('AUTH_CREATE_PROFILE', 'Creating user profile in database');
          await _supabaseService.createUserProfile(userProfile);
          _logger.i('AUTH_CREATE_PROFILE', 'User profile created successfully', {'userId': userId});

          emit(state.copyWith(
            status: app_auth.AuthStatus.authenticated,
            user: userProfile,
          ));
        } else {
          _logger.w('AUTH_CREATE_PROFILE', 'User email not found', {'userId': userId});
          emit(state.copyWith(
            status: app_auth.AuthStatus.error,
            errorMessage: 'User email not found. Please sign in again.',
          ));
        }
      } else {
        _logger.w('AUTH_CREATE_PROFILE', 'Not authenticated');
        emit(state.copyWith(
          status: app_auth.AuthStatus.error,
          errorMessage: 'Not authenticated. Please sign in again.',
        ));
      }
    } catch (e, stackTrace) {
      _logger.e('AUTH_CREATE_PROFILE', 'Failed to create profile', e, stackTrace);
      emit(state.copyWith(
        status: app_auth.AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAuthUpdateProfile(
    AuthUpdateProfileEvent event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    _logger.i('AUTH_UPDATE_PROFILE', 'Updating user profile', {
      'userId': event.user.id,
      'username': event.user.username
    });
    
    emit(state.copyWith(status: app_auth.AuthStatus.loading));

    try {
      _logger.d('AUTH_UPDATE_PROFILE', 'Calling updateUserProfile method');
      await _supabaseService.updateUserProfile(event.user);
      _logger.i('AUTH_UPDATE_PROFILE', 'Profile updated successfully');

      emit(state.copyWith(
        status: app_auth.AuthStatus.authenticated,
        user: event.user,
      ));
    } catch (e, stackTrace) {
      _logger.e('AUTH_UPDATE_PROFILE', 'Failed to update profile', e, stackTrace);
      emit(state.copyWith(
        status: app_auth.AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAuthSignOut(
    AuthSignOutEvent event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    _logger.i('AUTH_SIGN_OUT', 'Signing out user');
    emit(state.copyWith(status: app_auth.AuthStatus.loading));

    try {
      _logger.d('AUTH_SIGN_OUT', 'Calling signOut method');
      await _supabaseService.signOut();
      _logger.i('AUTH_SIGN_OUT', 'User signed out successfully');
      
      emit(state.copyWith(
        status: app_auth.AuthStatus.unauthenticated,
        user: null,
      ));
    } catch (e, stackTrace) {
      _logger.e('AUTH_SIGN_OUT', 'Failed to sign out', e, stackTrace);
      emit(state.copyWith(
        status: app_auth.AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
} 