import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'pin_service.dart';

/// Session service for managing app lock and timeout
/// When app goes to background or after inactivity, requires re-authentication
class SessionService extends WidgetsBindingObserver {
  // Singleton instance
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final PinService _pinService = PinService();
  static const String _lastActiveKey = 'last_active_time';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Configuration
  static const Duration inactivityTimeout = Duration(minutes: 5);
  
  // State
  bool _isLocked = false;
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  bool _isInSignupFlow = false;
  bool _isBiometricAuthInProgress = false;
  bool _lockScreenVisible = false; // FIX 2: Track if lock screen is actually visible
  DateTime? _lastActiveTime;
  VoidCallback? _onLockRequired;

  /// Whether the app is currently locked
  bool get isLocked => _isLocked;
  
  /// Whether user is logged in (has active session)
  bool get isLoggedIn => _isLoggedIn;
  
  /// Whether user is in signup flow (don't lock)
  bool get isInSignupFlow => _isInSignupFlow;
  
  /// Whether lock screen is currently visible in UI
  bool get lockScreenVisible => _lockScreenVisible;

  /// Initialize the session service
  void initialize({required VoidCallback onLockRequired}) async {
    if (_isInitialized) return;
    
    _onLockRequired = onLockRequired;
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    _lastActiveTime = DateTime.now();
    _saveLastActiveTime();
    
    // Load logged-in state
    await _loadLoggedInState();
    
    // Check if user is logged in AND has passcode - if so, lock on app start
    final hasPasscode = await _pinService.isPinEnabled();
    if (_isLoggedIn && hasPasscode) {
      lock();
    }
  }

  /// Set user as logged in (call after successful login/signup)
  Future<void> setLoggedIn(bool value) async {
    _isLoggedIn = value;
    await _secureStorage.write(key: _isLoggedInKey, value: value ? 'true' : 'false');
  }
  
  /// Set signup flow state (don't lock during signup)
  void setInSignupFlow(bool value) {
    _isInSignupFlow = value;
  }
  
  /// CRITICAL: Set biometric auth state - prevents lock() during biometric dialog
  void setBiometricAuthInProgress(bool value) {
    _isBiometricAuthInProgress = value;
  }
  
  /// FIX 2: Set lock screen visibility - prevents redundant lock() when already visible
  void setLockScreenVisible(bool value) {
    _lockScreenVisible = value;
  }
  
  Future<void> _loadLoggedInState() async {
    final value = await _secureStorage.read(key: _isLoggedInKey);
    _isLoggedIn = value == 'true';
  }

  /// Call this when user interacts with the app
  void recordActivity() {
    _lastActiveTime = DateTime.now();
    _saveLastActiveTime();
  }

  /// Check if session has timed out due to inactivity
  bool hasTimedOut() {
    if (_lastActiveTime == null) return true;
    return DateTime.now().difference(_lastActiveTime!) > inactivityTimeout;
  }

  /// Lock the session
  void lock() {
    // Don't lock if:
    // - not logged in
    // - during signup
    // - during biometric auth
    // - lock screen already visible (FIX 2)
    if (!_isLoggedIn || _isInSignupFlow || _isBiometricAuthInProgress || _lockScreenVisible) return;
    
    _isLocked = true;
    _lockScreenVisible = true; // Also set visibility when locking
    _onLockRequired?.call();
  }

  /// Unlock the session (after successful authentication)
  void unlock() {
    _isLocked = false;
    _lockScreenVisible = false; // Clear visibility when unlocking
    _lastActiveTime = DateTime.now();
    _saveLastActiveTime();
  }
  
  /// Logout - clear session but keep passcode preferences
  Future<void> logout() async {
    _isLoggedIn = false;
    _isLocked = false;
    _lockScreenVisible = false;
    await _secureStorage.write(key: _isLoggedInKey, value: 'false');
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background - record time
        _saveLastActiveTime();
        break;
      case AppLifecycleState.resumed:
        // App returning to foreground - check if should lock
        // FIX 2: Also check _lockScreenVisible to prevent redundant rebuilds
        if (_isLoggedIn && 
            !_isInSignupFlow && 
            !_isLocked && 
            !_lockScreenVisible &&  // FIX 2: Don't lock if already showing
            !_isBiometricAuthInProgress) {
          final hasPasscode = await _pinService.isPinEnabled();
          if (hasPasscode) {
            lock();
          }
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _saveLastActiveTime() async {
    if (_lastActiveTime != null) {
      await _secureStorage.write(
        key: _lastActiveKey,
        value: _lastActiveTime!.toIso8601String(),
      );
    }
  }

  Future<void> loadLastActiveTime() async {
    final stored = await _secureStorage.read(key: _lastActiveKey);
    if (stored != null) {
      _lastActiveTime = DateTime.tryParse(stored);
    }
  }

  /// Dispose observer
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }
}
