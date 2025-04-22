const Notification = require("../models/notifikasi");
const {
      messaging
} = require("../config/firebaseConfig");
const cron = require("node-cron");
const Kolam = require("../models/kolam");
const User = require("../models/users");

// 🔹 Kirim Push Notification ke Pengguna yang Login
const sendPushNotification = async (title, message, metadata = {}) => {
      if (!title || !message) {
            console.warn("⚠️ Notifikasi kosong tidak akan dikirim.");
            return;
      }

      const allowedTypes = ["feed_alert", "water_quality_alert", "threshold_update", "feed_schedule_update", "aerator_control_update"];
      const type = metadata.type;

      if (!allowedTypes.includes(type)) {
            console.warn(`⚠️ Jenis notifikasi tidak valid: ${type}`);
            return;
      }

      const payload = {
            topic: "global_notifications",
            notification: {
                  title: title,
                  body: message,
            },
            data: {
                  ...Object.fromEntries(
                        Object.entries(metadata).map(([key, value]) => [key, String(value)])
                  )
            },
            android: {
                  priority: "high",
                  notification: {
                        channelId: "high_importance_channel",
                  },
            },
            apns: {
                  payload: {
                        aps: {
                              alert: {
                                    title: title,
                                    body: message,
                              },
                              contentAvailable: true,
                        },
                  },
            },
      };

      try {
            await messaging.send(payload);
            console.log(`✅ Push notification sent: ${title} - ${message}`);
      } catch (error) {
            console.error("❌ Error sending push notification:", error);
      }
};

// 🔹 Simpan Notifikasi ke Database & Kirim Push Notification
const createNotification = async (data) => {
      try {
            const kolam = await Kolam.findOne({
                  idPond: data.idPond
            });
            if (!kolam) {
                  console.warn(`⚠️ Notifikasi dibatalkan: idPond ${data.idPond} tidak ditemukan di database.`);
                  return null;
            }

            const newNotification = new Notification(data);
            await newNotification.save();

            const metadata = {
                  id: newNotification._id,
                  type: data.type
            };

            await sendPushNotification(data.title, data.message, metadata);

            return newNotification;
      } catch (error) {
            console.error("❌ Error creating notification:", error);
            return null;
      }
};

// 🔹 Ambil Notifikasi Berdasarkan ID
const getNotificationById = async (id) => {
      return await Notification.findById(id);
};

// 🔹 Ambil Notifikasi Berdasarkan idPond
const getNotificationsByPondId = async (idPond) => {
      return await Notification.find({
            idPond
      }).sort({
            created_at: -1
      });
};

// 🔹 Tandai Notifikasi sebagai "Read"
const markNotificationAsRead = async (id) => {
      return await Notification.findByIdAndUpdate(id, {
            status: "read"
      }, {
            new: true
      });
};

// 🔹 Hapus Notifikasi yang Lebih dari 7 Hari
const deleteOldNotifications = async () => {
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      await Notification.deleteMany({
            created_at: {
                  $lt: sevenDaysAgo
            }
      });
      console.log("🗑️ Notifikasi lama berhasil dihapus!");
};

// ✅ Cron job untuk menghapus notifikasi lebih dari 7 hari (dijalankan setiap hari pukul 00:00)
cron.schedule("0 0 * * *", async () => {
      console.log("⏳ Menjalankan cron job untuk menghapus notifikasi lama...");
      await deleteOldNotifications();
}, {
      scheduled: true,
      timezone: "Asia/Jakarta",
});

// 🔹 Ekspor Modul
module.exports = {
      createNotification,
      getNotificationById,
      markNotificationAsRead,
      deleteOldNotifications,
      getNotificationsByPondId,
};