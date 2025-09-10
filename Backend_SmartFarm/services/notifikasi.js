const Notifikasi = require("../models/notifikasi");
const {
      messaging
} = require("../config/firebaseConfig");
const cron = require("node-cron");
const { DateTime } = require("luxon");
const Kolam = require("../models/kolam");

// Kirim Push Notifikasi
const kirimNotifikasi = async (title, message, metadata = {}) => {
      if (!title || !message) return;

      const allowedTypes = [
            "feed_alert",
            "water_quality_alert",
            "threshold_update",
            "feed_schedule_update",
            "aerator_control_update"
      ];

      const type = metadata.type;
      if (!allowedTypes.includes(type)) return;

      const payload = {
            topic: "global_notifications", // Kirim ke topik global_notifications
            notification: {
                  title,
                  body: message
            },
            data: Object.fromEntries(Object.entries(metadata).map(([k, v]) => [k, String(v)])),
            android: {
                  priority: "high",
                  notification: {
                        channelId: "high_importance_channel"
                  }
            },
            apns: {
                  payload: {
                        aps: {
                              alert: {
                                    title,
                                    body: message
                              },
                              contentAvailable: true
                        }
                  }
            }
      };

      try {
            await messaging.send(payload);
            console.log(`Notifikasi berhasil dikirim: ${title}`);
      } catch (error) {
            console.error("Gagal mengirim notifikasi:", error);
      }
};

// 🔹 Simpan Notifikasi ke DB & Push ke User
const buatNotifikasi = async (data) => {
      try {
            const kolam = await Kolam.model.findOne({
                  idPond: data.idPond
            });
            if (!kolam) {
                  console.warn(`idPond ${data.idPond} tidak ditemukan`);
                  return null;
            }

            const newNotif = await Notifikasi.buatNotifikasi(data);

            await kirimNotifikasi(data.title, data.message, {
                  id: newNotif._id,
                  type: data.type,
                  pondId: data.idPond,
                  namePond: kolam.namePond
            });

            return newNotif;
      } catch (error) {
            console.error("Gagal membuat notifikasi:", error);
            return null;
      }
};

const ambilNotifikasiById = async (id) => {
      return await Notifikasi.ambilNotifikasiById(id);
};

const ambilNotifikasiByPond = async (idPond) => {
      return await Notifikasi.ambilNotifikasiByPond(idPond);
};

const tandaiNotifikasi = async (id) => {
      return await Notifikasi.tandaiNotifikasi(id);
};

const hapusNotifikasi = async () => {
      await Notifikasi.hapusNotifikasi();
      console.log("Notifikasi lama dihapus");
};

// Penghapusan notifikasi
cron.schedule("0 17 * * *", async () => {
      console.log("Cron job: hapus notifikasi lama...");
      await hapusNotifikasi();
}, {
      scheduled: true,
      //timezone: "Asia/Jakarta"
});

module.exports = {
      buatNotifikasi,
      ambilNotifikasiById,
      ambilNotifikasiByPond,
      tandaiNotifikasi,
      hapusNotifikasi,
      kirimNotifikasi
};