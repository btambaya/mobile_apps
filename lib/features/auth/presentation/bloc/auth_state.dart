import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user.dart';

/// Auth states for the AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - processing auth action
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated - user is signed in
class AuthAuthenticated extends AuthState {
  final AuthUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Authenticated but needs passcode setup first
class AuthNeedsPasscodeSetup extends AuthState {
  final AuthUser user;

  const AuthNeedsPasscodeSetup(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated - no user signed in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Sign up success - needs email verification
class AuthSignUpSuccess extends AuthState {
  final String email;

  const AuthSignUpSuccess(this.email);

  @override
  List<Object?> get props => [email];
}

/// Confirm sign up success - can now sign in
class AuthConfirmSignUpSuccess extends AuthState {
  const AuthConfirmSignUpSuccess();
}

/// Code resent successfully
class AuthCodeResent extends AuthState {
  const AuthCodeResent();
}

/// Forgot password code sent
class AuthForgotPasswordCodeSent extends AuthState {
  final String email;

  const AuthForgotPasswordCodeSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Password reset successful
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

/// Auth error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Max devices reached - user needs to remove a device to continue
class AuthMaxDevicesReached extends AuthState {
  final AuthUser user;
  final List<dynamic> devices;

  const AuthMaxDevicesReached(this.user, this.devices);

  @override
  List<Object?> get props => [user, devices];
}

/// New device requires facial verification before login completes
class AuthNeedsFacialVerification extends AuthState {
  final AuthUser user;

  const AuthNeedsFacialVerification(this.user);

  @override
  List<Object?> get props => [user];
}
