# SplitEase - Web Deployment Guide

## Overview

**SplitEase** is a production-grade Flutter web application for splitting bills, tracking expenses, and settling payments with friends.

- **Platform:** Flutter Web (Web-only)
- **Backend:** Firebase (Firestore, Storage, Authentication)
- **Hosting:** Firebase Hosting
- **Version:** 1.0.0

---

## Development Setup

### Prerequisites
- Flutter SDK (3.5.0+)
- Node.js & npm (for Firebase CLI)
- Firebase CLI
- Git

### Local Development

```bash
# 1. Clone the repository
git clone https://github.com/abhishek-900/splitEase.git
cd splitEase

# 2. Copy environment file
cp .env.example .env
# Edit .env with your Firebase credentials

# 3. Install dependencies
flutter pub get

# 4. Run web app
flutter run -d chrome
# or
flutter run -d web-server
```

Access the app at `http://localhost:5000` (if using web-server)

---

## Production Build

### Build for Web

```bash
# Generate production build
flutter build web --release

# Output: build/web/
```

### Build Optimization

The build process automatically:
- ✅ Minifies JavaScript and CSS
- ✅ Compresses images
- ✅ Removes debug symbols
- ✅ Optimizes tree-shaking

Resulting file size: ~10-15 MB (before compression)

---

## Deployment to Firebase Hosting

### Prerequisites Setup

```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Select your project
firebase use budgetrix-621fc
# or set it in .firebaserc (already configured)
```

### Deploy Steps

```bash
# 1. Build the web app
flutter build web --release

# 2. Deploy to Firebase Hosting
firebase deploy --only hosting

# 3. View deployment
firebase open hosting:site
```

**Live URL:** `https://budgetrix-621fc.web.app`

### Deploy Only Specific Files

```bash
# Deploy only hosting (not functions, database rules, etc.)
firebase deploy --only hosting

# Deploy with specific message (for tracking)
firebase deploy --only hosting -m "Release v1.0.0"
```

---

## Environment Configuration

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select `budgetrix-621fc` project
3. Enable required services:
   - ✅ Authentication (Google Sign-In)
   - ✅ Firestore Database
   - ✅ Cloud Storage
   - ✅ Cloud Messaging (for notifications)

### Firestore Security Rules

**Location:** Firebase Console → Firestore → Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
```

### Cloud Storage Security

**Location:** Firebase Console → Storage → Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
```

---

## Performance Optimization

### Web Assets

Optimize images before deployment:

```bash
# Compress PNG images
pngquant --speed 1 --strip --force assets/images/*.png

# Compress JPG images
jpegoptim --max=85 assets/images/*.jpg
```

### Browser Caching

Configured in `firebase.json`:
```json
{
  "hosting": {
    "headers": [
      {
        "source": "**/*.js",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000" }]
      },
      {
        "source": "**/*.css",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000" }]
      },
      {
        "source": "index.html",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=3600" }]
      }
    ]
  }
}
```

---

## Monitoring & Analytics

### Google Analytics Integration

To enable analytics:

1. Go to Firebase Console
2. Navigate to Analytics
3. Update `.env` with your measurement ID:
   ```
   FIREBASE_WEB_MEASUREMENT_ID=G-XXXXX
   ```

### Error Tracking

Configure Firebase Crashlytics:

```bash
flutter pub add firebase_crashlytics
```

In `lib/main.dart`:
```dart
await FirebaseCrashlytics.instance.recordFlutterFatalError(exception);
```

---

## Deployment Checklist

Before deploying to production:

- [ ] Environment variables configured (`.env`)
- [ ] Firestore security rules reviewed and locked down
- [ ] Cloud Storage rules secure
- [ ] All sensitive data removed from git history
- [ ] Build tested locally: `flutter build web --release`
- [ ] No console errors in release build
- [ ] Firebase project limits verified (Firestore reads/writes)
- [ ] Email configured for password reset

---

## Rollback

If deployment fails:

```bash
# View deployment history
firebase hosting:channel:list

# Rollback to previous version
firebase hosting:clone budgetrix-621fc -t <previous-channel-name>
```

---

## Troubleshooting

### Issues with Google Sign-In

**Problem:** Google Sign-In redirects not working
```
Error: "Error initializing Google Sign-In"
```

**Solution:**
1. Go to Firebase Console → Authentication → Sign-in providers
2. Verify Google is enabled
3. Check that redirect URI includes your domain:
   - `https://budgetrix-621fc.web.app/__/auth/handler`

### Firestore Quota Exceeded

**Problem:** `QuotaExceededError`

**Solution:**
1. Check Firebase plan (Spark plan has limits)
2. Upgrade to Blaze plan for production
3. Implement proper indexing in Firestore

### Build Size Too Large

**Problem:** Web app taking too long to load

**Solution:**
```bash
# Analyze build size
flutter pub global activate dart_code_metrics
dcm analyze --html --github-flavor-resolve

# Build with size analysis
flutter build web --release --web-verbose-logging
```

---

## Security Best Practices

1. **Never commit sensitive data**
   - Use `.env` for all credentials
   - Verify `.gitignore` excludes `.env`

2. **Secure CORS**
   - Configure Firebase CORS settings

3. **Rate Limiting**
   - Use Firebase Security Rules to limit operations

4. **HTTPS Only**
   - Firebase Hosting auto-enables HTTPS

5. **Regular Updates**
   ```bash
   flutter pub upgrade
   flutter pub outdated
   ```

---

## Support & Documentation

- [Flutter Web Documentation](https://flutter.dev/web)
- [Firebase Web Documentation](https://firebase.google.com/docs/web)
- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [SplitEase GitHub Repository](https://github.com/abhishek-900/splitEase)

---

## License

This project is part of the SplitEase application.

For questions or issues, contact the development team.
