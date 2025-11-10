# Babel Binance Flutter Example App

A comprehensive Flutter application demonstrating advanced features including Appwrite backend, subscription management, biometric authentication, AI chat, media recording, and more.

## 🚀 Features

### 1. Appwrite Setup Wizard
- **4-Step Setup Process**
  - Welcome screen with requirements
  - Appwrite endpoint and project configuration
  - User account creation
  - Automatic database structure deployment
- **Auto-Push Database Structure**
  - 5 pre-configured collections (Users, Trades, Portfolios, Watchlist, Analytics)
  - Automatic attribute creation
  - Customizable schema support

### 2. Subscription System
- **RevenueCat Integration**
  - Monthly, annual, and lifetime plans
  - In-app purchase support
  - Restore purchases functionality
- **Beautiful Pricing UI**
  - Feature comparison
  - Popular plan highlighting
  - Subscription status management

### 3. Privacy Dashboard
- **Data Collection Controls**
  - Analytics toggle
  - Crash reporting
  - Location tracking
- **User Rights**
  - Data export request
  - Data deletion
  - Privacy policy access

### 4. Biometric Authentication
- **Multi-Step Setup Wizard**
  - Availability detection
  - Fingerprint/Face ID support
  - Fallback PIN authentication
- **Lock Screen Widget**
  - App background protection
  - Biometric unlock
  - PIN code fallback

### 5. Platform Channels (Native Bridge)
- **Android (Kotlin) & iOS (Swift)**
  - Battery level
  - Device information
  - Haptic feedback
  - Share content
  - Screen brightness
  - Clipboard operations
  - Root/jailbreak detection
  - Network information

### 6. AI Trading Assistant
- **Google Gemini Integration**
  - Real-time chat interface
  - Trading advice
  - Market analysis
  - Message history

### 7. Media Recording
- **Video Recording**
  - Front/back camera switching
  - High-resolution recording
  - Real-time preview
- **Audio Recording**
  - Duration tracking
  - High-quality audio
  - Save to device storage

### 8. Testing Suite
- **30%+ Code Coverage**
  - Appwrite service tests
  - Authentication tests
  - Platform channel tests
  - Database structure tests
  - Widget tests

### 9. Firebase Security
- **Firestore Rules**
  - User authentication
  - Role-based access
  - Data validation
- **Storage Rules**
  - File type validation
  - Size limits
  - User isolation

### 10. Modern Settings Page
- **Account Management**
  - Profile editing
  - Subscription management
  - API key configuration
- **Preferences**
  - Notifications
  - Dark mode
  - Language selection
- **Security**
  - Biometric setup
  - Privacy controls
  - Password change

## 📦 Dependencies

### Core
- `flutter`: SDK
- `flutter_riverpod`: State management
- `appwrite`: Backend integration

### Authentication & Security
- `firebase_auth`: Authentication
- `local_auth`: Biometric authentication
- `flutter_secure_storage`: Secure data storage

### Payments
- `purchases_flutter`: RevenueCat SDK
- `in_app_purchase`: Native IAP
- `stripe_flutter`: Stripe payments

### Location
- `geolocator`: GPS location
- `geofence_service`: Geofencing

### Media
- `camera`: Video recording
- `record`: Audio recording
- `image_picker`: Photo selection

### AI/ML
- `google_generative_ai`: Gemini AI

### Analytics
- `firebase_analytics`: Firebase Analytics
- `mixpanel_flutter`: Mixpanel
- `sentry_flutter`: Error tracking

### UI/UX
- `flutter_screenutil`: Responsive design
- `animations`: Advanced animations
- `lottie`: Lottie animations
- `cached_network_image`: Image caching

## 🛠️ Setup

### 1. Install Dependencies
```bash
cd example/flutter_app
flutter pub get
```

### 2. Configure Appwrite
- Create an Appwrite project at https://cloud.appwrite.io
- Copy your project ID
- Run the app and follow the setup wizard

### 3. Configure Firebase
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init

# Deploy security rules
firebase deploy --only firestore:rules,storage:rules
```

### 4. Configure API Keys
Edit `lib/src/config/app_config.dart` and add your API keys:
- RevenueCat API key
- Stripe publishable key
- Mixpanel token
- Gemini API key
- Binance API credentials

### 5. Run the App
```bash
flutter run
```

## 🧪 Running Tests
```bash
flutter test
```

For integration tests:
```bash
flutter test integration_test
```

## 📱 Platform-Specific Setup

### Android
1. Update `android/app/build.gradle` with required permissions
2. Set minimum SDK version to 21+
3. Add required permissions to `AndroidManifest.xml`

### iOS
1. Update `ios/Runner/Info.plist` with required permissions
2. Set minimum iOS version to 12.0+
3. Add required capabilities in Xcode

## 🔐 Security Features

### Firestore Rules
- User authentication required
- Owner-based access control
- Data validation
- Admin role support

### Storage Rules
- File type validation
- Size limits (5MB-100MB)
- User isolation
- Temporary file cleanup

### App Security
- Biometric authentication
- Secure storage for sensitive data
- Root/jailbreak detection
- Screen lock protection

## 📊 Database Structure

### Collections
1. **Users**: User profiles and preferences
2. **Trades**: Trading history and orders
3. **Portfolios**: Investment portfolios
4. **Watchlist**: Favorite trading pairs
5. **Analytics**: Event tracking

### Attributes
Each collection has properly typed attributes:
- String (with size limits)
- Integer (with min/max)
- Boolean
- Datetime

## 🎨 Theming

The app supports:
- Light mode
- Dark mode
- Custom color schemes
- Responsive layouts
- Accessibility features

## 🌍 Internationalization

Supported languages:
- English
- Español
- Français
- Deutsch
- 中文
- 日本語

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please read our contributing guidelines first.

## 📞 Support

For issues and questions:
- GitHub Issues: https://github.com/mayankjanmejay/babel_binance/issues
- Email: support@example.com

## 🙏 Acknowledgments

- Binance API for cryptocurrency data
- Appwrite for backend services
- RevenueCat for subscription management
- Google for Gemini AI
- All open-source contributors

---

Built with ❤️ using Flutter and Babel Binance
