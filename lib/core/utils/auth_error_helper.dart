/// Cognito Error Helper
/// Converts raw Cognito/AWS exceptions to user-friendly error messages

class AuthErrorHelper {
  /// Convert any auth exception to a user-friendly message
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Password requirements
    if (errorString.contains('invalidpasswordexception') ||
        errorString.contains('password did not conform')) {
      return 'Password must be at least 8 characters with uppercase, lowercase, number, and special character';
    }
    
    // Incorrect password
    if (errorString.contains('notauthorizedexception') ||
        errorString.contains('incorrect username or password')) {
      return 'Incorrect email or password';
    }
    
    // User not found
    if (errorString.contains('usernotfoundexception') ||
        errorString.contains('user does not exist')) {
      return 'No account found with this email';
    }
    
    // User not confirmed
    if (errorString.contains('usernotconfirmedexception')) {
      return 'Please verify your email before signing in';
    }
    
    // Code expired
    if (errorString.contains('expiredcodeexception') ||
        errorString.contains('code has expired')) {
      return 'Verification code has expired. Please request a new one';
    }
    
    // Invalid code
    if (errorString.contains('codemismatchexception') ||
        errorString.contains('invalid verification code')) {
      return 'Invalid verification code';
    }
    
    // User already exists
    if (errorString.contains('usernameexistsexception') ||
        errorString.contains('already exists')) {
      return 'An account with this email already exists';
    }
    
    // Too many requests
    if (errorString.contains('limitexceededexception') ||
        errorString.contains('too many requests')) {
      return 'Too many attempts. Please try again later';
    }
    
    // Invalid email
    if (errorString.contains('invalidemail') ||
        errorString.contains('invalid email')) {
      return 'Please enter a valid email address';
    }
    
    // Network issues
    if (errorString.contains('networkerror') ||
        errorString.contains('socketexception') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your connection';
    }
    
    // Password policy details
    if (errorString.contains('password must have')) {
      if (errorString.contains('uppercase')) {
        return 'Password must include an uppercase letter';
      }
      if (errorString.contains('lowercase')) {
        return 'Password must include a lowercase letter';
      }
      if (errorString.contains('numeric')) {
        return 'Password must include a number';
      }
      if (errorString.contains('symbol') || errorString.contains('special')) {
        return 'Password must include a special character (!@#\$%^&*)';
      }
    }
    
    // Invalid session
    if (errorString.contains('invalid session') ||
        errorString.contains('no user session')) {
      return 'Session expired. Please sign in again';
    }
    
    // Password history
    if (errorString.contains('password has been used')) {
      return 'Cannot reuse a recent password';
    }
    
    // Generic fallback - extract meaningful part
    if (error is Exception) {
      final message = error.toString();
      // Try to extract the message part
      if (message.contains('Exception:')) {
        final parts = message.split('Exception:');
        if (parts.length > 1) {
          return parts.last.trim();
        }
      }
    }
    
    return 'Something went wrong. Please try again';
  }
  
  /// Check if error indicates user needs to verify email
  static bool isUnconfirmedUser(dynamic error) {
    return error.toString().toLowerCase().contains('usernotconfirmedexception');
  }
  
  /// Check if error is due to expired session
  static bool isSessionExpired(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('invalid session') ||
           errorString.contains('no user session') ||
           errorString.contains('session expired');
  }
}
