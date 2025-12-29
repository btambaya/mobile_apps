# Device Management - AWS Setup Guide

## Overview

This document outlines the AWS infrastructure needed for the 3-device limit feature.

---

## 1. DynamoDB Table: `thryve-user-devices`

### Create Table (AWS Console or CLI)

```bash
aws dynamodb create-table \
  --table-name thryve-user-devices \
  --attribute-definitions \
    AttributeName=user_id,AttributeType=S \
    AttributeName=device_id,AttributeType=S \
  --key-schema \
    AttributeName=user_id,KeyType=HASH \
    AttributeName=device_id,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST
```

### Schema

| Field | Type | Description |
|-------|------|-------------|
| `user_id` | String (PK) | Cognito user ID |
| `device_id` | String (SK) | Unique device identifier |
| `device_name` | String | e.g., "iPhone 15 Pro" |
| `platform` | String | "ios" or "android" |
| `last_login` | String | ISO timestamp |
| `created_at` | String | ISO timestamp |

---

## 2. Lambda Function: `thryve-device-management`

### Endpoints

| Method | Path | Action |
|--------|------|--------|
| POST | `/user/devices` | Register device on login |
| GET | `/user/devices` | List user's devices |
| DELETE | `/user/devices/{device_id}` | Remove a device |

### Lambda Code (Python)

```python
import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('thryve-user-devices')
MAX_DEVICES = 3

def lambda_handler(event, context):
    user_id = event['requestContext']['authorizer']['claims']['sub']
    http_method = event['httpMethod']
    
    if http_method == 'GET':
        return get_devices(user_id)
    elif http_method == 'POST':
        body = json.loads(event['body'])
        return register_device(user_id, body)
    elif http_method == 'DELETE':
        device_id = event['pathParameters']['device_id']
        return delete_device(user_id, device_id)

def get_devices(user_id):
    response = table.query(
        KeyConditionExpression='user_id = :uid',
        ExpressionAttributeValues={':uid': user_id}
    )
    return {
        'statusCode': 200,
        'body': json.dumps({'devices': response['Items']})
    }

def register_device(user_id, body):
    # Check device count
    devices = table.query(
        KeyConditionExpression='user_id = :uid',
        ExpressionAttributeValues={':uid': user_id}
    )['Items']
    
    # Check if this device already exists
    for d in devices:
        if d['device_id'] == body['device_id']:
            # Update last_login
            table.update_item(
                Key={'user_id': user_id, 'device_id': body['device_id']},
                UpdateExpression='SET last_login = :t',
                ExpressionAttributeValues={':t': datetime.utcnow().isoformat()}
            )
            return {'statusCode': 200, 'body': json.dumps({'status': 'updated'})}
    
    # Check if at max devices
    if len(devices) >= MAX_DEVICES:
        return {
            'statusCode': 409,
            'body': json.dumps({
                'error': 'max_devices_reached',
                'devices': devices,
                'message': 'You have reached the maximum of 3 devices. Please remove one to continue.'
            })
        }
    
    # Register new device
    table.put_item(Item={
        'user_id': user_id,
        'device_id': body['device_id'],
        'device_name': body['device_name'],
        'platform': body['platform'],
        'last_login': datetime.utcnow().isoformat(),
        'created_at': datetime.utcnow().isoformat()
    })
    
    return {'statusCode': 201, 'body': json.dumps({'status': 'registered'})}

def delete_device(user_id, device_id):
    table.delete_item(Key={'user_id': user_id, 'device_id': device_id})
    return {'statusCode': 200, 'body': json.dumps({'status': 'deleted'})}
```

---

## 3. API Gateway Routes

Add to existing API Gateway (`thryve-api`):

| Method | Resource | Lambda |
|--------|----------|--------|
| GET | `/user/devices` | `thryve-device-management` |
| POST | `/user/devices` | `thryve-device-management` |
| DELETE | `/user/devices/{device_id}` | `thryve-device-management` |

---

## 4. Flutter Integration

### Device Service (after AWS setup)

```dart
// lib/core/services/device_service.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  final ApiService _apiService = ApiService();
  
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor ?? 'unknown';
    } else {
      final android = await deviceInfo.androidInfo;
      return android.id;
    }
  }
  
  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.utsname.machine; // e.g., "iPhone15,2"
    } else {
      final android = await deviceInfo.androidInfo;
      return '${android.brand} ${android.model}';
    }
  }
  
  Future<Map<String, dynamic>> registerDevice() async {
    return await _apiService.post('/user/devices', {
      'device_id': await getDeviceId(),
      'device_name': await getDeviceName(),
      'platform': Platform.isIOS ? 'ios' : 'android',
    });
  }
  
  Future<List<dynamic>> getDevices() async {
    final response = await _apiService.get('/user/devices');
    return response['devices'];
  }
  
  Future<void> removeDevice(String deviceId) async {
    await _apiService.delete('/user/devices/$deviceId');
  }
}
```

### Dependency

Add to `pubspec.yaml`:
```yaml
dependencies:
  device_info_plus: ^10.1.0
```

---

## 5. Login Flow Changes

1. On successful login → call `registerDevice()`
2. If response is `409` (max devices):
   - Parse `devices` array from response
   - Show dialog for user to pick device to remove
   - After removal, retry registration

---

*After AWS setup is complete, the Flutter integration can be implemented.*
