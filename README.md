# SplitEase - Expense Tracker

Production-grade Flutter expense sharing app with BLoC architecture, Clean Architecture, and Firebase integration.

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase Project

### Local Development Setup

#### 1. Clone the repository
```bash
git clone https://github.com/abhishek-900/splitEase.git
cd splitEase
```

#### 2. Install dependencies
```bash
flutter pub get
```

#### 3. Configure Firebase Credentials

This project uses `.env` files to manage sensitive credentials. Never commit actual Firebase credentials to Git.

**Step 1: Copy the environment template**
```bash
cp .env.example .env
```

**Step 2: Update `.env` with your Firebase credentials**

Get your Firebase credentials from [Firebase Console](https://console.firebase.google.com/):

1. Go to your Firebase Project Settings
2. Download credentials for each platform:
   - **Web**: Project Settings → Your apps → Web app
   - **Android**: Download `google-services.json`
   - **iOS**: Download `GoogleService-Info.plist`

3. Fill in `.env` with your actual values:
```env
# Web Configuration
FIREBASE_WEB_API_KEY=AIzaSy...
FIREBASE_WEB_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_WEB_PROJECT_ID=your-project-id
FIREBASE_WEB_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_WEB_MESSAGING_SENDER_ID=123456789
FIREBASE_WEB_APP_ID=1:123456789:web:abc123def456
FIREBASE_WEB_MEASUREMENT_ID=G-XXXXXXXXXX

# Android Configuration
FIREBASE_ANDROID_API_KEY=AIzaSy...
FIREBASE_ANDROID_APP_ID=1:123456789:android:abc123def456
FIREBASE_ANDROID_SENDER_ID=123456789

# iOS Configuration
FIREBASE_IOS_API_KEY=AIzaSy...
FIREBASE_IOS_APP_ID=1:123456789:ios:abc123def456
FIREBASE_IOS_SENDER_ID=123456789

# Google Sign-In
GOOGLE_SIGNIN_CLIENT_ID=123456789-abcdefghijk.apps.googleusercontent.com

# App Configuration
APP_BASE_URL=https://your-project.firebaseapp.com
```

#### 4. Run the app
```bash
flutter pub get
flutter run
```

### Important: Git Configuration

- ✅ `.env` is in `.gitignore` - your credentials won't be committed
- ✅ `.env.example` is committed - shows the structure for team members
- ✅ Firebase config files (`google-services.json`, `GoogleService-Info.plist`) are also gitignored

**Never commit:**
- `.env` (contains real credentials)
- `android/app/google-services.json` (Android Firebase config)
- `ios/Runner/GoogleService-Info.plist` (iOS Firebase config)
- `lib/firebase_options.dart` (generated from .env)

## Project Structure

```
lib/
├── core/              # App-wide utilities and configuration
│   ├── constants/
│   ├── di/            # Dependency injection
│   ├── error/
│   ├── network/
│   ├── router/        # Go Router configuration
│   ├── services/
│   ├── theme/
│   └── utils/
├── features/          # Feature modules (Clean Architecture)
│   ├── auth/
│   ├── dashboard/
│   ├── expenses/
│   ├── groups/
│   ├── notifications/
│   └── settlements/
└── main.dart
```

## Architecture

- **BLoC Pattern**: State management with bloc and flutter_bloc
- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- **Dependency Injection**: Using GetIt for service locator pattern
- **Firebase**: Authentication, Firestore database, and Cloud Messaging

## Security

- Environment variables are used for all sensitive credentials
- Firebase credentials are never committed to Git
- Use `.env.example` as a template for team collaboration

## For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
