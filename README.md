# SplitEase 💰

[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter Version](https://img.shields.io/badge/flutter-3.5.0+-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/dart-3.5.0+-blue.svg)](https://dart.dev)
[![Web Only](https://img.shields.io/badge/platform-web%20only-green.svg)](https://flutter.dev/web)

**SplitEase** - A production-grade Flutter web application for splitting bills, tracking expenses, and settling payments with friends easily.

**Live Demo:** [https://budgetrix-621fc.web.app](https://budgetrix-621fc.web.app)

---

## ✨ Features

- 👥 **Create & Manage Groups** - Form expense groups with friends
- 💳 **Track Expenses** - Log shared expenses with category and description
- 🔄 **Automatic Settlement** - Calculate who owes whom
- 👤 **User Authentication** - Secure Google Sign-In
- 📱 **Responsive Design** - Works on desktop and mobile browsers
- 🌙 **Dark Mode** - Toggle between light and dark themes
- 🔔 **Real-time Notifications** - Get updates on group activities
- 📊 **Expense Analytics** - View spending patterns and balances
- 🎯 **Smart Calculations** - Efficient settlement algorithms

---

## 🛠 Tech Stack

### Frontend
- **Framework:** [Flutter](https://flutter.dev/) (Web)
- **State Management:** [BLoC](https://bloclibrary.dev/) + [Provider](https://pub.dev/packages/provider)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router)
- **UI Libraries:** Flutter Material Design

### Backend & Services
- **Database:** [Google Firestore](https://firebase.google.com/products/firestore)
- **Authentication:** [Firebase Auth](https://firebase.google.com/products/auth) (Google Sign-In)
- **Storage:** [Firebase Storage](https://firebase.google.com/products/storage)
- **Hosting:** [Firebase Hosting](https://firebase.google.com/products/hosting)
- **Notifications:** [Firebase Cloud Messaging](https://firebase.google.com/products/cloud-messaging)

### Architecture
- **Pattern:** Clean Architecture
- **Dependency Injection:** [GetIt](https://pub.dev/packages/get_it)
- **Code Generation:** [Injectable](https://pub.dev/packages/injectable)
- **Logging:** [Logger](https://pub.dev/packages/logger)

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK >= 3.5.0
- Dart SDK >= 3.5.0
- Firebase Account
- A modern web browser

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/abhishek-900/splitEase.git
cd splitEase
```

**2. Copy environment configuration**
```bash
cp .env.json.example .env.json
```

**3. Set up Firebase credentials**

Navigate to [Firebase Console](https://console.firebase.google.com/) and:
1. Create a new project or select existing
2. Enable Google Authentication
3. Create a web app
4. Copy your credentials into `.env.json`:

```json
{
  "FIREBASE_WEB_API_KEY": "your_api_key_here",
  "FIREBASE_WEB_AUTH_DOMAIN": "your-project.firebaseapp.com",
  "FIREBASE_WEB_PROJECT_ID": "your-project-id",
  "FIREBASE_WEB_STORAGE_BUCKET": "your-project.appspot.com",
  "FIREBASE_WEB_MESSAGING_SENDER_ID": "your_sender_id"
FIREBASE_WEB_APP_ID=your_app_id
FIREBASE_WEB_MEASUREMENT_ID=your_measurement_id
GOOGLE_SIGNIN_CLIENT_ID=your_client_id
```

**4. Install dependencies**
```bash
flutter pub get
```

**5. Run the app**
```bash
flutter run -d chrome
# or for web server
flutter run -d web-server
```

The app will open in your browser at `http://localhost:5000`

---

## 📁 Project Structure

```
lib/
├── core/                          # App-wide configuration
│   ├── constants/                 # App constants
│   ├── di/                        # Dependency injection setup
│   ├── error/                     # Error handling
│   ├── network/                   # API configurations
│   ├── router/                    # Route management
│   ├── services/                  # Logging, notifications, etc.
│   ├── theme/                     # App themes (light/dark)
│   └── utils/                     # Utility functions
├── features/                      # Feature modules (Clean Architecture)
│   ├── auth/                      # Authentication
│   │   ├── data/                  # Data layer (repositories, datasources)
│   │   ├── domain/                # Business logic (entities, usecases)
│   │   └── presentation/          # UI (pages, blocs, widgets)
│   ├── dashboard/                 # Home/dashboard screen
│   ├── expenses/                  # Expense management
│   ├── groups/                    # Group management
│   ├── notifications/             # Notifications feature
│   └── settlements/               # Payment settlements
├── main.dart                      # App entry point
└── firebase_options.dart          # Firebase configuration (auto-generated)

pubspec.yaml                       # Dependencies
.env.json.example                  # Environment template
README.md                          # This file
CONTRIBUTING.md                   # Contribution guidelines
```

---

## 🏗 Architecture

### Clean Architecture Pattern

Each feature follows the **Clean Architecture** pattern with three layers:

```
Presentation Layer (UI)
        ↓
Domain Layer (Business Logic)
        ↓
Data Layer (Repositories & APIs)
```

**Benefits:**
- ✅ Testable business logic
- ✅ Independent of frameworks
- ✅ Scalable and maintainable
- ✅ Easy to modify and extend

### State Management with BLoC

- **BLoC (Business Logic Component)** handles complex logic
- **Events** represent user actions
- **States** represent UI states
- **Streams** enable reactive programming

---

## 🔐 Security & Environment

### Environment Variables
All sensitive data is managed through `.env.json` file using `--dart-define-from-file`:
- ✅ Firebase API keys (from .env.json)
- ✅ Google Sign-In credentials (from .env.json)
- ✅ App configuration (from .env.json)

### `.gitignore` Protection
```
.env.json                         # Never committed (contains real credentials)
.env.json.example                 # Committed (shows structure)
google-services.json              # Platform-specific Firebase config
GoogleService-Info.plist          # iOS Firebase config
lib/firebase_options.dart         # Generated from environment variables
```

### Best Practices
- Never hardcode sensitive data
- Use `.env.json.example` for team onboarding
- Always pass `--dart-define-from-file=.env.json` when building
- Rotate credentials regularly
- Use Firebase Security Rules

---

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test --tags="widget"

# Integration tests
flutter drive --target=test_driver/app.dart
```

Currently, the project structure supports testing. Add tests to `test/` directory:
```
test/
├── features/
│   └── auth/
│       ├── domain/
│       │   └── usecases_test.dart
│       └── data/
│           └── repositories_test.dart
└── core/
    └── utils/
        └── helper_test.dart
```

---

## 📦 Build & Deployment

### Web Build (Production)

```bash
# Build for web
flutter build web --release

# Output: build/web/
```

### Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy
firebase deploy --only hosting
```

**Live URL:** `https://budgetrix-621fc.web.app`

### Performance Optimization
- Minified JavaScript and CSS
- Image compression
- Lazy loading
- Code splitting via Flutter

---

## 🐛 Troubleshooting

### Google Sign-In Issues
```
Error: "Error initializing Google Sign-In"
```
**Solution:**
- Verify Google Sign-In enabled in Firebase Console
- Check `.env.json` has correct `GOOGLE_SIGNIN_CLIENT_ID`
- Clear browser cache and cookies
- Rebuild with: `flutter build web --dart-define-from-file=.env.json`

### Firestore Connection Issues
```
Error: "Permission denied" or "Not authenticated"
```
**Solution:**
- Verify Firestore Security Rules in Firebase Console
- Ensure user is authenticated before data access
- Check Firestore Rules allow read/write for authenticated users

### Build Size Issues
```
Error: "App taking too long to load"
```
**Solution:**
```bash
# Analyze build
flutter build web --release --analyze-size

# Enable caching headers in firebase.json
# Check for unused dependencies: flutter pub outdated
```

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### 1. Fork the Repository
```bash
git clone https://github.com/YOUR_USERNAME/splitEase.git
cd splitEase
```

### 2. Create a Feature Branch
```bash
git checkout -b feature/AmazingFeature
```

### 3. Make Changes
- Follow the existing code style (dart analysis_options.yaml)
- Add tests for new features
- Update documentation

### 4. Commit Changes
```bash
git commit -m 'feat: add AmazingFeature'
# Use conventional commits: feat:, fix:, docs:, refactor:, etc.
```

### 5. Push & Create Pull Request
```bash
git push origin feature/AmazingFeature
```
Then create a Pull Request on GitHub

### Code Style
- Follow Dart [effective Dart](https://dart.dev/guides/language/effective-dart)
- Run `flutter analyze` before committing
- Use `flutter format` for consistency

### Reporting Issues
- Use [GitHub Issues](https://github.com/abhishek-900/splitEase/issues)
- Provide clear description and steps to reproduce
- Include Flutter version and environment details

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### MIT License Summary
- ✅ Use commercially
- ✅ Modify freely
- ✅ Distribute copies
- ❌ Sublicense or trademark
- ❌ Hold liable

---

## 👨‍💻 Authors

**Abhishek** - [GitHub](https://github.com/abhishek-900)

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Firebase](https://firebase.google.com) for backend services
- [BLoC Library](https://bloclibrary.dev/) for state management
- Community contributors and testers

---

## 📞 Support

### Getting Help
- 📖 Read the [Flutter Documentation](https://flutter.dev/docs)
- 💬 Open an [Issue](https://github.com/abhishek-900/splitEase/issues)
- 📧 Contact maintainers

### Related Resources
- [Flutter Web Documentation](https://flutter.dev/web)
- [Firebase Documentation](https://firebase.google.com/docs)
- [BLoC Pattern Guide](https://bloclibrary.dev/#/coreconcepts)
- [Clean Architecture in Flutter](https://resocoder.com/clean-architecture-tdd)

---

## 🎯 Roadmap

Future features planned:
- [ ] Mobile app (iOS/Android)
- [ ] Advanced analytics & reports
- [ ] Payment integration (Stripe/PayPal)
- [ ] Recurring expenses
- [ ] Budget planning
- [ ] Export to PDF/CSV
- [ ] Multi-currency support
- [ ] Offline mode

---

## 📱 Responsive Design

**Desktop:** Full-featured interface
**Tablet:** Optimized layout
**Mobile:** Touch-friendly design

All tested with [flutter_screenutil](https://pub.dev/packages/flutter_screenutil)

---

## ⭐ Show Your Support

If you found this project helpful, please consider:
- ⭐ Giving it a star
- 🔗 Sharing with friends
- 🐛 Reporting bugs
- 💡 Suggesting improvements
- 🤝 Contributing code

---

**Made with ❤️ by the SplitEase community**
