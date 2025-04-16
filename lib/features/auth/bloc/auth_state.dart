part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user; // Firebase user object

  const AuthState._({this.status = AuthStatus.unknown, this.user});

  // Initial state
  const AuthState.unknown() : this._();

  // Authenticated state
  const AuthState.authenticated(User user)
    : this._(status: AuthStatus.authenticated, user: user);

  // Unauthenticated state
  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}
