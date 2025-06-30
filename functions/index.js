/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp();

exports.sendNotificationOnCreate = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snap, context) => {
      const notification = snap.data();
      const userId = notification.userId;

      // Fetch the user's FCM token from Firestore
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .get();
      const fcmToken = userDoc.get("fcmToken");

      if (!fcmToken) {
        console.log(`No FCM token for user ${userId}`);
        return null;
      }

      // Compose the notification payload
      const payload = {
        notification: {
          title: notification.title || "Notification",
          body: notification.message || "",
          sound: "default",
        },
        data: {
          orderId: notification.orderId || "",
          status: notification.status || "",
        },
      };

      // Send the notification
      try {
        await admin.messaging().sendToDevice(fcmToken, payload);
        console.log(`Notification sent to user ${userId}`);
      } catch (error) {
        console.error("Error sending notification:", error);
      }

      return null;
    });
