part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Event triggered when the auth state changes (e.g., user logs in/out)
class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

// Event triggered to request sign out
class AuthSignOutRequested extends AuthEvent {}

// Event triggered to send a welcome notification
class AuthSendWelcomeNotification extends AuthEvent {
  final String userId;
  final String? displayName;
  const AuthSendWelcomeNotification({required this.userId, this.displayName});

  @override
  List<Object?> get props => [userId, displayName];
}

class CheckbackendHealth extends AuthEvent {
  const CheckbackendHealth();

  @override
  List<Object?> get props => [];
}
