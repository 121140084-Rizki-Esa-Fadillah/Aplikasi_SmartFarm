const admin = require("firebase-admin");

try {
    if (!admin.apps.length) {
        const serviceAccount = require("../firebase-admin.json");

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            databaseURL: "https://app-sadewa-smartfarm-default-rtdb.asia-southeast1.firebasedatabase.app/",
        });

        console.log("✅ Firebase Admin SDK initialized (FCM HTTP v1)");
    }
} catch (error) {
    console.error("❌ Error initializing Firebase Admin SDK:", error);
}

const db = admin.database();
const messaging = admin.messaging();

module.exports = {
    db,
    messaging
};