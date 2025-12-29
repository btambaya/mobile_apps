import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../../../core/services/pin_service.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/utils/auth_error_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC - manages authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthConfirmSignUpRequested>(_onConfirmSignUpRequested);
    on<AuthResendCodeRequested>(_onResendCodeRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthConfirmForgotPasswordRequested>(_onConfirmForgotPasswordRequested);
    on<AuthBiometricLoginRequested>(_onBiometricLoginRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        givenName: event.givenName,
        familyName: event.familyName,
        phoneNumber: event.phoneNumber,
        countryCode: event.countryCode,
      );
      emit(AuthSignUpSuccess(event.email));
    } on CognitoClientException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (e) {
      emit(AuthError(AuthErrorHelper.getErrorMessage(e)));
    }
  }

  Future<void> _onConfirmSignUpRequested(
    AuthConfirmSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.confirmSignUp(
        email: event.email,
        code: event.code,
      );
      emit(const AuthConfirmSignUpSuccess());
    } on CognitoClientException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResendCodeRequested(
    AuthResendCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.resendConfirmationCode(event.email);
      emit(const AuthCodeResent());
    } on CognitoClientException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      
      // Register this device
      final deviceService = DeviceService();
      final deviceResult = await deviceService.registerDevice();
      
      // Check if max devices reached
      if (deviceResult.maxDevicesReached) {
        emit(AuthMaxDevicesReached(user, deviceResult.devices));
        return;
      }
      
      // New device requires facial verification
      if (deviceResult.isNewDevice) {
        emit(AuthNeedsFacialVerification(user));
        return;
      }
      
      // Existing device - proceed to passcode check
      await _proceedToPasscodeCheck(user, emit);
    } on CognitoClientException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  /// Helper to check passcode and emit appropriate state
  Future<void> _proceedToPasscodeCheck(AuthUser user, Emitter<AuthState> emit) async {
    final pinService = PinService();
    var hasPasscode = await pinService.isPinEnabled();
    
    // If no local passcode, try to sync from Cognito (cross-device login)
    if (!hasPasscode) {
      final synced = await pinService.syncFromCloud();
      hasPasscode = synced;
    }
    
    if (hasPasscode) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthNeedsPasscodeSetup(user));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.forgotPassword(event.email);
      emit(AuthForgotPasswordCodeSent(event.email));
    } on CognitoClientException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onConfirmForgotPasswordRequested(
    AuthConfirmForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.confirmForgotPassword(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      );
      emit(const AuthPasswordResetSuccess());
    } on CognitoClientException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Biometric auth already passed at this point
      // Try to restore session from stored tokens
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        // Check if passcode is set up
        final pinService = PinService();
        final hasPasscode = await pinService.isPinEnabled();
        
        if (hasPasscode) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthNeedsPasscodeSetup(user));
        }
      } else {
        emit(const AuthError('Session expired. Please login with password.'));
      }
    } catch (e) {
      emit(const AuthError('Session expired. Please login with password.'));
    }
  }

  /// Parse Cognito errors into user-friendly messages
  String _parseError(CognitoClientException e) {
    switch (e.code) {
      case 'UsernameExistsException':
        return 'An account with this email already exists';
      case 'InvalidPasswordException':
        return 'Password must be at least 8 characters with uppercase, lowercase, numbers, and symbols';
      case 'UserNotFoundException':
        return 'No account found with this email';
      case 'NotAuthorizedException':
        return 'Incorrect email or password';
      case 'UserNotConfirmedException':
        return 'Please verify your email first';
      case 'CodeMismatchException':
        return 'Invalid verification code';
      case 'ExpiredCodeException':
        return 'Verification code has expired. Please request a new one';
      case 'LimitExceededException':
        return 'Too many attempts. Please try again later';
      case 'InvalidParameterException':
        return 'Invalid input. Please check your details';
      default:
        return e.message ?? 'An error occurred. Please try again';
    }
  }
}
