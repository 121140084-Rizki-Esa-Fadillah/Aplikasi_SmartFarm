const admin = require("firebase-admin");
require("dotenv").config();

try {
    if (!admin.apps.length) {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            databaseURL: "https://app-smartfarm-bd7d2-default-rtdb.asia-southeast1.firebasedatabase.app/",
        });
        console.log("Firebase Admin SDK initialized (FCM HTTP v1)");
    }
} catch (error) {
    console.error("Error initializing Firebase Admin SDK:", error);
}

const db = admin.database();
const messaging = admin.messaging();

module.exports = {
    db,
    messaging
};