# Firebase Setup Guide - Fix Permission Issues

## Step 1: Set Firestore to Test Mode

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `e-commerce-5ee74`
3. Go to **Firestore Database** in the left sidebar
4. Click on the **Rules** tab
5. Replace the current rules with this test mode configuration:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

6. Click **Publish** to save the rules

## Step 2: Set Storage to Test Mode

1. Go to **Storage** in the left sidebar
2. Click on the **Rules** tab
3. Replace the current rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

4. Click **Publish** to save the rules

## Step 3: Enable Authentication

1. Go to **Authentication** in the left sidebar
2. Click **Get started** if not already done
3. Go to **Sign-in method** tab
4. Enable **Email/Password** authentication
5. Click **Save**

## Step 4: Add Sample Data

After setting up test mode, you can add sample products using the app's "Firebase Test" button (blue cloud icon) in the home screen.

## Step 5: Test the Setup

1. Run your Flutter app: `flutter run`
2. Try to register a new user
3. Check if products load without permission errors
4. Test the complete order flow

## Important Notes

- **Test mode allows all reads and writes** - this is for development only
- **Before production**, you must update the security rules to be more restrictive
- The test mode rules above will fix your permission denied errors immediately

## Production Security Rules (for later)

When ready for production, replace the test rules with:

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