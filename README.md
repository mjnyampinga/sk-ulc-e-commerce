# E-Commerce Flutter App

A modern, feature-rich e-commerce mobile application built with Flutter, featuring Firebase backend, real-time connectivity monitoring, and multi-language support.

## 📱 App Overview

This e-commerce app provides a complete shopping experience with features for both customers and suppliers, including:

- **Customer Features**: Product browsing, shopping cart, order management, payment processing
- **Supplier Features**: Product management, order fulfillment, banner management, analytics
- **Admin Features**: Product approval system, user management
- **Real-time Features**: Connectivity monitoring, offline support, push notifications

### 🎥 Introduction Video
Watch our [5-minute introduction video](https://drive.google.com/file/d/1AeXceqnb21qFbyOyX3GzBR_7gtP31mBE/view?usp=sharing) to see the app in action and learn about its core functionalities.

## 🛠️ Technical Stack

- **Framework**: Flutter 3.1.3+
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging, Analytics)
- **State Management**: Provider
- **Local Storage**: Hive, SharedPreferences
- **Maps**: Flutter Map with OpenStreetMap
- **Connectivity**: connectivity_plus
- **Internationalization**: Flutter Localizations (English & French)

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: 3.1.3 or higher
- **Dart SDK**: 3.1.3 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control
- **Firebase CLI** (optional, for Firebase configuration)

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ecommerce_app
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Generate Localization Files

The app uses Flutter's internationalization system. Generate the localization files:

```bash
flutter gen-l10n
```

### 4. Generate Hive Models

The app uses Hive for local data storage. Generate the Hive adapters:

```bash
flutter packages pub run build_runner build
```

### 5. Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable the following Firebase services:
   - Authentication (Email/Password, Phone)
   - Cloud Firestore
   - Storage
   - Cloud Messaging
   - Analytics

3. Download the configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

4. Update Firebase configuration in your project files as needed.

### 6. Run the Application

#### Development Mode
```bash
flutter run
```

#### Release Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📱 App Features & Usage

### 🔐 Authentication

#### Customer Registration/Login
- **Email Authentication**: Use email and password
- **Phone Authentication**: Use phone number (creates account without verification)
- **User Types**: Customer or Supplier

#### Seller Login Credentials
```
Email: j.nyampinga@alustudent.com
Password: 211203Nyampinga.
```

### 🛍️ Customer Features

#### Shopping Experience
1. **Browse Products**: View products by category or search
2. **Add to Cart**: Add products with quantity validation
3. **Cart Management**: View, modify, or remove items
4. **Checkout**: Complete purchase with payment options

#### Payment Options
- **Cash on Delivery**: Pay when receiving the order
- **Mobile Money (MoMo)**: Digital payment processing

#### Order Management
- **Order History**: View all past orders
- **Order Status**: Track order progress (Pending, Confirmed, Processing, Shipped, Delivered)
- **Order Details**: View complete order information

### 🏪 Supplier Features

#### Product Management
- **Add Products**: Upload product details, images, and pricing
- **Product Approval**: Products require admin approval before public listing
- **Stock Management**: Track and update product quantities
- **Category Management**: Organize products by categories

#### Order Management
- **Order Dashboard**: View and manage incoming orders
- **Order Status Updates**: Update order status (Confirmed, Processing, Shipped, Delivered)
- **Order Filtering**: Filter orders by status

#### Banner Management
- **Promotional Banners**: Create and manage promotional content
- **Banner Scheduling**: Set banner display periods

### 🔧 Admin Features

#### Product Approval System
- **Pending Products**: Review products awaiting approval
- **Approval Actions**: Approve or reject products with comments
- **Approved Products**: Manage previously approved products

#### User Management
- **User Roles**: Manage customer and supplier accounts
- **Access Control**: Role-based feature access

### 🌐 Connectivity Features

#### Real-time Connectivity Monitoring
- **Online/Offline Detection**: Automatic connectivity status detection
- **Payment Protection**: Prevents payment processing when offline
- **Visual Indicators**: Clear connectivity status display
- **Offline Support**: Queue operations for when connection is restored

#### Connectivity Checks
- **Payment Validation**: Ensures internet connection before payment
- **Data Synchronization**: Syncs offline data when online
- **User Notifications**: Clear messages about connectivity requirements

### 🌍 Internationalization

The app supports multiple languages:
- **English** (Default)
- **French**

Language switching is available in the app settings.

## 📁 Project Structure

```
lib/
├── core/
│   ├── services/          # Business logic and API services
│   ├── theme/            # App theming and styling
│   └── utils/            # Utility functions and constants
├── data/
│   └── models/           # Data models and Hive adapters
├── ui/
│   ├── screens/          # App screens and pages
│   │   ├── auth/         # Authentication screens
│   │   ├── cart/         # Shopping cart screens
│   │   ├── categories/   # Product category screens
│   │   ├── home/         # Home screen
│   │   ├── menu/         # Menu and profile screens
│   │   ├── onboarding/   # Onboarding screens
│   │   ├── splash/       # Splash screen
│   │   └── supplier/     # Supplier management screens
│   └── widgets/          # Reusable UI components
└── l10n/                 # Localization files
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory for environment-specific configurations:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
```

### Firebase Rules
Ensure your Firebase Firestore rules allow appropriate access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Add your security rules here
  }
}
```

## 📦 Build & Deploy

### Android APK
```bash
flutter build apk --release
```
The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA
```bash
flutter build ios --release
```

## 📱 Download APK

[Download App-Release.apk](app-release.apk)

The APK file is available in the project root directory. Click the link above to download the latest version of the app.

## 🐛 Troubleshooting

### Common Issues

1. **Flutter Version Mismatch**
   ```bash
   flutter doctor
   flutter upgrade
   ```

2. **Dependencies Issues**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build Issues**
   ```bash
   flutter build apk --debug
   ```

4. **Firebase Configuration**
   - Ensure all Firebase configuration files are properly placed
   - Verify Firebase project settings and API keys
   - Check Firebase console for any service restrictions

### Debug Mode
Run the app in debug mode for detailed error information:
```bash
flutter run --debug
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the Firebase console for backend issues

## 🔄 Version History

- **v1.0.0**: Initial release with core e-commerce features
- Added product approval system
- Implemented real-time connectivity monitoring
- Added multi-language support (English & French)
- Integrated Firebase backend services

---

**Note**: This README will be updated as new features are added and configurations change. Always refer to the latest version for the most current information.
