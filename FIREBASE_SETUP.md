# Firebase Setup Guide for E-Commerce App

This guide will help you set up Firebase for your Flutter e-commerce application.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Android Studio or VS Code
4. Firebase CLI (optional but recommended)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "e-commerce-app")
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Enable Firebase Services

In your Firebase project console, enable the following services:

### Authentication
1. Go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Optionally enable "Google" sign-in for Google authentication

### Firestore Database
1. Go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location for your database
5. Click "Done"

### Storage
1. Go to "Storage" in the left sidebar
2. Click "Get started"
3. Choose "Start in test mode" for development
4. Select a location for your storage
5. Click "Done"

### Cloud Messaging (Optional)
1. Go to "Cloud Messaging" in the left sidebar
2. This will be automatically configured when you add your app

## Step 3: Add Android App

1. In the Firebase console, click the Android icon to add an Android app
2. Enter your Android package name: `e.commerce`
3. Enter app nickname (optional)
4. Click "Register app"
5. Download the `google-services.json` file
6. Place the `google-services.json` file in the `android/app/` directory of your Flutter project

## Step 4: Add iOS App (if developing for iOS)

1. In the Firebase console, click the iOS icon to add an iOS app
2. Enter your iOS bundle ID: `com.example.eCommerce`
3. Enter app nickname (optional)
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place the `GoogleService-Info.plist` file in the `ios/Runner/` directory of your Flutter project

## Step 5: Install Dependencies

The Firebase dependencies have already been added to your `pubspec.yaml` file. Run:

```bash
flutter pub get
```

## Step 6: Configure Firestore Security Rules

In the Firebase console, go to Firestore Database > Rules and update the rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read and write their own cart
    match /users/{userId}/cart/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read products
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == 'Supplier';
    }
    
    // Users can read and write their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

## Step 7: Configure Storage Security Rules

In the Firebase console, go to Storage > Rules and update the rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow users to upload their own profile images
    match /users/{userId}/profile/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow suppliers to upload product images
    match /products/{productId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.userType == 'Supplier';
    }
  }
}
```

## Step 8: Test the Setup

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Try to register a new user account
3. Check the Firebase console to see if the user was created in Authentication
4. Check Firestore to see if the user document was created

## Step 9: Add Sample Data (Optional)

You can add sample products to your Firestore database. In the Firebase console:

1. Go to Firestore Database
2. Click "Start collection"
3. Collection ID: `products`
4. Add documents with the following structure:

```json
{
  "name": "Sample Product",
  "subtitle": "Product description",
  "imageUrl": "https://example.com/image.jpg",
  "price": 29.99,
  "description": "Detailed product description",
  "category": "electronics",
  "hasDiscount": false,
  "quantity": 10
}
```

## Troubleshooting

### Common Issues:

1. **"google-services.json not found"**
   - Make sure the file is in the correct location: `android/app/google-services.json`

2. **"GoogleService-Info.plist not found"**
   - Make sure the file is in the correct location: `ios/Runner/GoogleService-Info.plist`

3. **Authentication errors**
   - Check that Email/Password authentication is enabled in Firebase console
   - Verify your Firebase configuration files are correct

4. **Firestore permission errors**
   - Check your Firestore security rules
   - Make sure you're in test mode during development

5. **Build errors**
   - Run `flutter clean` and then `flutter pub get`
   - Make sure all Firebase dependencies are properly installed

## Next Steps

1. Implement Google Sign-In (optional)
2. Add push notifications
3. Set up Firebase Analytics
4. Configure production security rules
5. Set up Firebase Hosting for web deployment

## Security Notes

- The current setup uses test mode for development
- Before deploying to production, update security rules to be more restrictive
- Never commit your actual Firebase configuration files to public repositories
- Use environment variables for sensitive configuration in production

## Support

If you encounter any issues:
1. Check the Firebase documentation
2. Review the Flutter Firebase plugin documentation
3. Check the Firebase console for error logs
4. Ensure all configuration files are properly placed and formatted 