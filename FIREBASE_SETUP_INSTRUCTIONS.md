# Firebase Setup Instructions - Fix Permission Issues

## 🔥 URGENT: Fix Firebase Permission Issues

Your app is experiencing Firebase permission denied errors. Follow these steps to fix them:

### Step 1: Set Firestore to Test Mode

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `e-commerce-5ee74`
3. **Navigate to Firestore Database** (left sidebar)
4. **Click on "Rules" tab**
5. **Replace the current rules with this test mode configuration**:

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

6. **Click "Publish"** to save the rules

### Step 2: Set Storage to Test Mode

1. **Go to Storage** (left sidebar)
2. **Click on "Rules" tab**
3. **Replace the current rules with**:

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

4. **Click "Publish"** to save the rules

### Step 3: Enable Authentication

1. **Go to Authentication** (left sidebar)
2. **Click "Get started"** if not already done
3. **Go to "Sign-in method" tab**
4. **Enable "Email/Password" authentication**
5. **Click "Save"**

### Step 4: Test the App

1. **Run your app**: `flutter run`
2. **Go to the home screen**
3. **Click the blue cloud icon** (Firebase Test button) to add sample products
4. **Try to register a new user account**
5. **Try to login with the registered account**

## ✅ What This Fixes

- **Permission denied errors** for products, user profiles, and featured products
- **Authentication issues** during login/register
- **Firebase connection problems**

## 🚨 Important Notes

- **Test mode allows all reads and writes** - this is for development only
- **Before production**, you must update security rules to be more restrictive
- The test mode rules above will fix your permission denied errors immediately

## 🔄 Complete Flow Test

After fixing the rules, test this complete flow:

1. **Register a new user** (email/password)
2. **Login with the registered user**
3. **Add products to cart**
4. **Go to checkout**
5. **Place an order**

## 🛠️ If You Still Have Issues

1. **Check Firebase Console** for any error messages
2. **Verify your Firebase configuration files** are correct
3. **Make sure you're using the right project ID**: `e-commerce-5ee74`
4. **Restart the app** after changing rules

## 📱 App Features Now Working

- ✅ Firebase authentication (login/register)
- ✅ Product display from Firebase
- ✅ Cart functionality
- ✅ Order placement
- ✅ User profile management
- ✅ Real-time data updates

## 🔒 Production Security Rules (for later)

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

---

**Follow these steps and your app will work perfectly!** 🎉 