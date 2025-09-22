# Environment Variables Setup

This project uses environment variables to manage API keys and configuration securely.

## Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Fill in your actual values in `.env`:
   ```env
   # Firebase Configuration
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_PROJECT_NUMBER=your_project_number
   FIREBASE_STORAGE_BUCKET=your_storage_bucket
   FIREBASE_APP_ID=your_app_id
   FIREBASE_API_KEY=your_api_key

   # Google OAuth
   GOOGLE_CLIENT_ID=your_google_client_id
   GOOGLE_WEB_CLIENT_ID=your_google_web_client_id

   # Android Configuration
   ANDROID_PACKAGE_NAME=com.example.your_app
   ANDROID_CERTIFICATE_HASH=your_certificate_hash

   # Environment
   ENVIRONMENT=development
   ```

## Usage in Code

Import the config:
```dart
import '../config/env_config.dart';
```

Use environment variables:
```dart
// Firebase config
String apiKey = EnvConfig.firebaseApiKey;
String projectId = EnvConfig.firebaseProjectId;

// Google OAuth
String clientId = EnvConfig.googleClientId;

// Environment check
bool isProduction = EnvConfig.isProduction;
```

## Security Notes

- The `.env` file is ignored by Git (added to `.gitignore`)
- Never commit actual API keys to version control
- Use `.env.example` as a template for other developers
- Keep the `.env` file secure and don't share it

## Migration from google-services.json

The app now uses environment variables instead of `google-services.json` for:
- Firebase configuration
- Google OAuth client IDs
- Android package configuration

This provides better security and flexibility across different environments.