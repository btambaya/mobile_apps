# AWS Cognito Authentication - Complete Guide

## AWS Resources

| Resource | Name/ID | Region |
|----------|---------|--------|
| User Pool | `us-east-1_5eWwc0y7h` | us-east-1 |
| App Client | `6sfchnp8u913osd1kagk7hquj3` | us-east-1 |
| DynamoDB Table | `thryve-users` | us-east-1 |
| Lambda Function | `thryve-post-confirmation` | us-east-1 |

---

## Part 1: AWS Setup (Completed)

### 1.1 Cognito User Pool
1. AWS Console → Cognito → Create user pool
2. Application type: **Mobile app**
3. Name: `thryve user pool`
4. Sign-in: **Email only**
5. Password: Cognito defaults (8+ chars, mixed case, numbers, symbols)
6. MFA: **Disabled**
7. Email verification: **Required**
8. Self-registration: **Enabled**
9. App client: `thryve-mobile-app` (no client secret)

### 1.2 DynamoDB Table
1. Table name: `thryve-users`
2. Partition key: `user_id` (String)
3. Settings: Default

### 1.3 Lambda Function

**Name:** `thryve-post-confirmation`  
**Runtime:** Python 3.12

```python
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('thryve-users')

def lambda_handler(event, context):
    # Only run for signup confirmation
    if event['triggerSource'] != 'PostConfirmation_ConfirmSignUp':
        return event
    
    attrs = event['request']['userAttributes']
    
    # Create user record in DynamoDB
    table.put_item(Item={
        'user_id': attrs['sub'],
        'email': attrs['email'],
        'phone_number': attrs.get('phone_number', ''),
        'country': attrs.get('custom:country', 'NG'),
        'given_name': attrs.get('given_name', ''),
        'family_name': attrs.get('family_name', ''),
        'created_at': datetime.utcnow().isoformat(),
        'kyc_status': 'not_started',
        'phone_verified': False,
    })
    
    return event
```

**IAM Role:** Add `AmazonDynamoDBFullAccess` policy

### 1.4 Connect Lambda to Cognito
1. Cognito → User pool → Extensions
2. Add Lambda trigger → Post confirmation
3. Select `thryve-post-confirmation`

### 1.5 Add Custom Attribute (for country)
1. Cognito → User pool → Sign-up experience
2. Click "Add custom attributes"
3. Name: `country`
4. Type: String
5. Max length: 2
6. Mutable: Yes

> [!IMPORTANT]
> Custom attributes must be created BEFORE users sign up with them. 
> Attribute names in code use `custom:country` format.

---

## Part 1.5: Flow Pseudocode

### Sign Up Flow
```
USER selects country (Nigeria default, locked for now)
USER enters first_name, last_name, email, phone, password on RegisterPage
  ↓
APP validates input (email format, phone format, password requirements)
APP formats phone as E.164: +234XXXXXXXXXX
  ↓
APP calls CognitoAuthDatasource.signUp(email, password, first_name, last_name, phone, country)
  ↓
COGNITO creates unconfirmed user with attributes:
  - email
  - given_name
  - family_name  
  - phone_number (E.164 format)
  - custom:country (e.g., "NG")
COGNITO sends verification email with 6-digit code
  ↓
APP navigates to VerifyOtpPage with email
  ↓
USER enters 6-digit code
  ↓
APP calls CognitoAuthDatasource.confirmSignUp(email, code)
  ↓
COGNITO confirms user
COGNITO triggers Lambda (PostConfirmation_ConfirmSignUp)
  ↓
LAMBDA creates record in DynamoDB:
  {
    user_id: cognito_sub,
    email: user_email,
    phone_number: "+234...",
    country: "NG",
    given_name: first_name,
    family_name: last_name,
    created_at: timestamp,
    kyc_status: "not_started",
    phone_verified: false
  }
  ↓
APP shows success message
APP navigates to LoginPage
```

### Sign In Flow
```
USER enters email, password on LoginPage
  ↓
APP calls CognitoAuthDatasource.signIn(email, password)
  ↓
COGNITO validates credentials
COGNITO returns JWT tokens (access, id, refresh)
  ↓
APP stores tokens in FlutterSecureStorage:
  - cognito_access_token
  - cognito_id_token  
  - cognito_refresh_token
  - cognito_email
  ↓
APP parses user attributes from id_token
APP creates AuthUser entity
  ↓
AuthBloc emits AuthAuthenticated(user)
  ↓
APP navigates to HomePage
```

### Auto-Login Flow (App Startup)
```
APP launches SplashPage
  ↓
APP reads tokens from FlutterSecureStorage
  ↓
IF tokens exist:
  APP creates CognitoUserSession from stored tokens
    ↓
  IF session.isValid():
    APP fetches user attributes
    APP navigates to HomePage
  ELSE:
    APP calls cognitoUser.refreshSession(refreshToken)
      ↓
    IF refresh succeeds:
      APP stores new tokens
      APP navigates to HomePage
    ELSE:
      APP clears stored tokens
      APP navigates to OnboardingPage
ELSE:
  APP navigates to OnboardingPage
```

### Forgot Password Flow
```
USER enters email on ForgotPasswordPage
  ↓
APP calls CognitoAuthDatasource.forgotPassword(email)
  ↓
COGNITO sends password reset code to email
  ↓
USER enters code + new password
  ↓
APP calls CognitoAuthDatasource.confirmForgotPassword(email, code, newPassword)
  ↓
IF success:
  APP shows success message
  APP navigates to LoginPage
ELSE:
  APP shows error (invalid code, expired, etc.)
```

### Sign Out Flow
```
USER taps "Sign Out" in SettingsPage
  ↓
APP calls CognitoAuthDatasource.signOut()
  ↓
COGNITO invalidates session
  ↓
APP clears all stored tokens from FlutterSecureStorage
APP sets _cognitoUser = null
APP sets _session = null
  ↓
AuthBloc emits AuthUnauthenticated()
  ↓
APP navigates to OnboardingPage
```

### Token Refresh Flow (API Calls)
```
APP needs to make authenticated API call
  ↓
APP reads accessToken from storage
  ↓
IF accessToken is expired (or will expire in 5 min):
  APP calls CognitoAuthDatasource.refreshSession()
    ↓
  COGNITO validates refreshToken
  COGNITO returns new accessToken + idToken
    ↓
  APP stores new tokens
  ↓
APP makes API call with Authorization: Bearer {accessToken}
```

---

## Part 2: Flutter Implementation (Completed)

### 2.1 Dependencies Added
```yaml
dependencies:
  amazon_cognito_identity_dart_2: ^3.8.1
```

### 2.2 Files Created

```
lib/
├── core/
│   └── config/
│       └── auth_config.dart           # Cognito credentials
│
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   └── cognito_auth_datasource.dart  # Direct Cognito SDK calls
        │   └── repositories/
        │       └── auth_repository_impl.dart     # Repository implementation
        │
        ├── domain/
        │   ├── entities/
        │   │   └── auth_user.dart                # User entity
        │   └── repositories/
        │       └── auth_repository.dart          # Repository interface
        │
        └── presentation/
            └── bloc/
                ├── auth_bloc.dart                # State management
                ├── auth_event.dart               # Events
                └── auth_state.dart               # States
```

### 2.3 Key Files

#### auth_config.dart
```dart
class AuthConfig {
  static const String userPoolId = 'us-east-1_5eWwc0y7h';
  static const String clientId = '6sfchnp8u913osd1kagk7hquj3';
  static const String region = 'us-east-1';
  // Token storage keys
  static const String accessTokenKey = 'cognito_access_token';
  static const String idTokenKey = 'cognito_id_token';
  static const String refreshTokenKey = 'cognito_refresh_token';
}
```

#### cognito_auth_datasource.dart
Handles all Cognito operations:
- `signUp()` - Register new user
- `confirmSignUp()` - Verify email with code
- `signIn()` - Authenticate and get tokens
- `signOut()` - Clear session
- `forgotPassword()` - Initiate password reset
- `confirmForgotPassword()` - Complete password reset
- `getCurrentUser()` - Restore session from storage
- `refreshSession()` - Refresh tokens

#### auth_bloc.dart
Events:
- `AuthCheckRequested` - Check session on app start
- `AuthSignUpRequested` - Register new user
- `AuthConfirmSignUpRequested` - Verify email
- `AuthSignInRequested` - Login
- `AuthSignOutRequested` - Logout
- `AuthForgotPasswordRequested` - Reset password
- `AuthConfirmForgotPasswordRequested` - Complete reset

States:
- `AuthInitial` - Starting state
- `AuthLoading` - Processing
- `AuthAuthenticated` - Logged in
- `AuthUnauthenticated` - Logged out
- `AuthSignUpSuccess` - Registration complete, needs verification
- `AuthConfirmSignUpSuccess` - Email verified
- `AuthError` - Error with message

### 2.4 Pages Updated

| Page | Changes |
|------|---------|
| `splash_page.dart` | Auto-login check via `getCurrentUser()` |
| `login_page.dart` | Uses AuthBloc for Cognito signIn |
| `register_page.dart` | Uses AuthBloc for Cognito signUp with password requirements |
| `verify_otp_page.dart` | Uses AuthBloc for confirmSignUp |

### 2.5 Password Requirements (Cognito Default)
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character (!@#$%^&*)

---

## Part 3: Testing

### Test Sign Up Flow
1. Run app: `flutter run`
2. Go to Register page
3. Enter first name, last name, email, password
4. Click "Create Account"
5. Check email for verification code
6. Enter 6-digit code on verification page
7. On success, redirects to login page

### Test Sign In Flow
1. Go to Login page
2. Enter email and password
3. Click "Sign In"
4. On success, redirects to home page

### Test Auto-Login
1. Sign in successfully
2. Close app completely
3. Reopen app
4. Should auto-redirect to home (if session valid)

### Test Sign Out
1. Go to Settings page
2. Tap "Sign Out"
3. Should redirect to onboarding

### Verify DynamoDB
1. AWS Console → DynamoDB → Tables → thryve-users
2. Check for new user record after signup confirmation

---

## Part 4: Error Handling

The AuthBloc parses Cognito errors into user-friendly messages:

| Cognito Error | User Message |
|---------------|--------------|
| UsernameExistsException | An account with this email already exists |
| InvalidPasswordException | Password must be at least 8 characters... |
| UserNotFoundException | No account found with this email |
| NotAuthorizedException | Incorrect email or password |
| UserNotConfirmedException | Please verify your email first |
| CodeMismatchException | Invalid verification code |
| ExpiredCodeException | Verification code has expired |
| LimitExceededException | Too many attempts. Please try again later |

---

## Part 5: Phone Verification & MFA Strategy

### Verification Strategy

| What | When | Method |
|------|------|--------|
| Email | Signup | Cognito (automatic) ✅ |
| Phone | Signup (once) | SNS via Lambda (planned) |
| MFA | Login | Email code (required) + SMS (optional) |

### Phone Verification Flow (Planned)
```
AFTER email confirmed:
  ↓
APP prompts "Verify your phone number"
  ↓
APP calls Lambda → SNS to send SMS code
  ↓
USER enters SMS code
  ↓
APP calls Lambda to verify code
  ↓
LAMBDA updates DynamoDB: phone_verified = true
```

### MFA Configuration

**Plan:** Email-first MFA with optional SMS

1. **Email MFA (Required):**
   - Use Cognito custom auth flow or separate Lambda
   - Send code to verified email on login

2. **SMS MFA (Optional):**
   - Only available after phone_verified = true
   - User can enable in Settings

---

## Part 6: Country & Currency Configuration

### Supported Countries

| Code | Name | Dial | Currency | Symbol |
|------|------|------|----------|--------|
| NG | Nigeria | +234 | NGN | ₦ |

> More countries coming: US (+1, USD), GB (+44, GBP), GH (+233, GHS)

### How Country Affects App

| Setting | Determined By |
|---------|---------------|
| Currency display | `country` |
| Phone number format | `country.dialCode` |
| Bank options | `country` |
| Regulatory compliance | `country` |
| Default language | `country` |

---

## Next Steps

- [x] Register page with phone/country fields
- [x] Cognito signUp with phone_number attribute
- [x] Lambda stores phone/country in DynamoDB
- [x] Add `custom:country` attribute in Cognito console
- [x] Update Lambda in AWS with new code
- [x] Sign out button connected to AuthRepository
- [x] Forgot password flow (3-step with Cognito)
- [x] Biometric authentication (Face ID/Fingerprint)
- [ ] Implement phone verification via SNS
- [ ] Implement email MFA for login (Lambda)
- [ ] Set up SES for production emails

---

*Updated: December 27, 2024*
