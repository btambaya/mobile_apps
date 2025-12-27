import 'package:equatable/equatable.dart';

/// Auth events for the AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Sign up with email and password
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String givenName;
  final String familyName;
  final String? phoneNumber;
  final String? countryCode;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.givenName,
    required this.familyName,
    this.phoneNumber,
    this.countryCode,
  });

  @override
  List<Object?> get props => [email, password, givenName, familyName, phoneNumber, countryCode];
}

/// Confirm sign up with verification code
class AuthConfirmSignUpRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthConfirmSignUpRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

/// Resend confirmation code
class AuthResendCodeRequested extends AuthEvent {
  final String email;

  const AuthResendCodeRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Sign in with email and password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign out current user
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Initiate forgot password flow
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Confirm forgot password with new password
class AuthConfirmForgotPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  const AuthConfirmForgotPasswordRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}
