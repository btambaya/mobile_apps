# User Profile API Documentation

## Overview

REST API to fetch user profile data from DynamoDB, protected by Cognito JWT authentication.

| Resource | Value |
|----------|-------|
| API Name | `thryve-api` |
| Base URL | `https://y1mheifune.execute-api.us-east-1.amazonaws.com/prod` |
| Stage | `prod` |
| Region | `us-east-1` |
| Auth | Cognito User Pool JWT |

---

## Architecture

```
Mobile App → API Gateway → Lambda → DynamoDB
     ↑
JWT Token (from Cognito)
```

---

## Endpoints

### GET /user/profile

Fetch the authenticated user's profile from DynamoDB.

**Authorization:** Cognito ID Token (NOT Access Token)

**Request:**
```
GET /user/profile
Authorization: {id_token}
```

> **Note:** The Authorization header must contain the raw ID token without "Bearer" prefix.
> Cognito Authorizer validates the token and passes user claims to Lambda.

**Response (200 OK):**
```json
{
  "user_id": "abc-123-uuid",
  "email": "user@example.com",
  "given_name": "John",
  "family_name": "Doe",
  "phone_number": "+2348012345678",
  "country": "NG",
  "kyc_status": "not_started",
  "phone_verified": false,
  "created_at": "2024-12-27T20:00:00Z"
}
```

**Error Responses:**
- `401` - Unauthorized (invalid/missing token)
- `404` - User not found in DynamoDB
- `500` - Server error

---

## AWS Setup

### 1. Create Lambda Function

**Name:** `thryve-get-user-profile`  
**Runtime:** Python 3.12  
**Timeout:** 10 seconds

```python
import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('thryve-users')

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super().default(obj)

def lambda_handler(event, context):
    # Get user_id from JWT claims (set by API Gateway authorizer)
    try:
        claims = event['requestContext']['authorizer']['claims']
        user_id = claims['sub']
    except KeyError:
        return {
            'statusCode': 401,
            'headers': cors_headers(),
            'body': json.dumps({'error': 'Unauthorized'})
        }
    
    # Fetch user from DynamoDB
    try:
        response = table.get_item(Key={'user_id': user_id})
        
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': cors_headers(),
                'body': json.dumps({'error': 'User not found'})
            }
        
        user = response['Item']
        
        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps(user, cls=DecimalEncoder)
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': cors_headers(),
            'body': json.dumps({'error': str(e)})
        }

def cors_headers():
    return {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Authorization,Content-Type',
        'Access-Control-Allow-Methods': 'GET,OPTIONS'
    }
```

**IAM Permissions:** Add `AmazonDynamoDBReadOnlyAccess`

---

### 2. Create API Gateway

1. **Create REST API**
   - API Gateway → Create API → REST API
   - Name: `thryve-api`
   - Endpoint type: Regional

2. **Create Cognito Authorizer**
   - Authorizers → Create → Cognito
   - Name: `cognito-authorizer`
   - User Pool: `us-east-1_5eWwc0y7h`
   - Token Source: `Authorization`

3. **Create Resource and Method**
   - Create Resource: `/user`
   - Create Resource: `/user/profile`
   - Create Method: `GET`
   - Integration: Lambda (`thryve-get-user-profile`)
   - **Lambda Proxy Integration: ENABLED** ← CRITICAL!
   - Authorization: `cognito-authorizer`

4. **Enable CORS**
   - Actions → Enable CORS
   - Allow all origins for now

5. **Deploy API**
   - Actions → Deploy API
   - Stage: `prod`
   - Note the Invoke URL

---

### 3. Get API URL

After deployment, your API URL will be:
```
https://{api-id}.execute-api.us-east-1.amazonaws.com/prod
```

Example endpoints:
- `GET https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/user/profile`

---

## Client-Side Caching

The app uses a **permanent cache** for user profiles via `UserProfileService` singleton.

### Cache Flow

```
USER opens ProfilePage
  ↓
IF cache exists → return cache (INSTANT!)
  ↓
ELSE → fetch from API → cache → return
  ↓
USER opens EditProfilePage → return cache (INSTANT!)
  ↓
USER opens NotificationsPage → return cache (INSTANT!)
  ↓
USER logs out → cache CLEARED
```

### Cache Methods

| Method | Usage |
|--------|-------|
| `getProfile()` | Returns cache if available, else fetches |
| `refreshProfile()` | Force fetch from API, update cache |
| `clearCache()` | Clear cache (called on logout) |
| `hasCache` | Check if profile is cached |

### Implementation

```dart
// All pages use the same singleton
final _profileService = UserProfileService();

// Check cache first (instant!)
if (_profileService.hasCache) {
  _profile = _profileService.cachedProfile;
  return;
}

// Fetch from service (caches automatically)
_profile = await _profileService.getProfile();
```

---

## KYC Locking

After KYC is approved (`kyc_status: 'approved'`), the user's profile fields are **permanently locked**.

### Locked Fields (after KYC)
- ❌ First Name
- ❌ Last Name  
- ❌ Phone Number
- ❌ Email (always locked)

### Editable After KYC
- ✅ Profile Photo

### UI Behavior

```dart
bool get _isProfileLocked => _profile?.isKycComplete ?? false;

// Fields disabled when locked
_buildTextField(
  enabled: !_isProfileLocked,
  ...
);

// Save button hidden when locked
if (!_isProfileLocked) SaveButton(...)
```

---

## Future Endpoints

| Method | Path | Description |
|--------|------|-------------|
| PUT | /user/profile | Update profile |
| POST | /user/profile/photo | Upload profile photo |
| POST | /user/phone/verify | Send phone verification |
| POST | /user/phone/confirm | Confirm phone with code |
| GET | /user/kyc/status | Get KYC status |

---

*Created: December 27, 2024*  
*Updated: December 27, 2024 - Added caching and KYC locking*

