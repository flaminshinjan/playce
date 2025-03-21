import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playce/blocs/auth/auth_event.dart';
import 'package:playce/blocs/auth/auth_state.dart';
import 'package:playce/utils/supabase_logger.dart';

/// A BLoC observer that logs events and state changes related to Supabase operations
class SupabaseBlocObserver extends BlocObserver {
  final SupabaseLogger _logger = SupabaseLogger();

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    
    // Log auth bloc events specifically
    if (event is AuthEvent) {
      _logger.i('BLOC_EVENT', '${bloc.runtimeType}: ${event.runtimeType}', {
        'bloc': bloc.runtimeType.toString(),
        'event': event.toString(),
      });
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    // Log auth transitions
    if (transition.event is AuthEvent) {
      _logger.d('BLOC_TRANSITION', '${bloc.runtimeType}: ${transition.event.runtimeType}', {
        'bloc': bloc.runtimeType.toString(),
        'event': transition.event.toString(),
        'currentState': transition.currentState.toString(),
        'nextState': transition.nextState.toString(),
      });
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.e(
      'BLOC_ERROR',
      '${bloc.runtimeType} error',
      {
        'bloc': bloc.runtimeType.toString(),
        'error': error.toString(),
      },
      stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    
    // Log auth bloc state changes
    if (change.currentState is AuthState || change.nextState is AuthState) {
      _logger.d('BLOC_CHANGE', '${bloc.runtimeType} changed', {
        'bloc': bloc.runtimeType.toString(),
        'currentState': change.currentState.toString(),
        'nextState': change.nextState.toString(),
      });
    }
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.d('BLOC_CREATE', 'Created ${bloc.runtimeType}');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.d('BLOC_CLOSE', 'Closed ${bloc.runtimeType}');
  }
} 