const {
      db
} = require("../config/firebaseConfig");
const {
      buatNotifikasi
} = require("./notifikasi");
const Kolam = require("../models/kolam");
const Notification = require("../models/notifikasi"); // Import model notifikasi

// 🔹 Fungsi untuk mencegah notifikasi duplikat dalam 5 menit terakhir
const isDuplicateNotification = async (idPond, type) => {
      // Hanya periksa duplikasi untuk jenis 'feed_alert'
      if (type !== "feed_alert") return false;

      const checkTime = new Date();
      checkTime.setMinutes(checkTime.getMinutes() - 5);

      const existingNotification = await Notification.model.findOne({
            idPond,
            type,
            time: {
                  $gte: checkTime
            }
      });

      return !!existingNotification;
};


const previousValues = {};

// 🔹 Fungsi untuk mengambil nilai awal dari Firebase
const initializePreviousValues = async () => {
      const pondsRef = db.ref("Sadewa_SmartFarm/ponds");
      const pondsSnapshot = await pondsRef.once("value");
      const pondsData = pondsSnapshot.val();

      if (pondsData) {
            Object.keys(pondsData).forEach((pondId) => {
                  const pondData = pondsData[pondId];

                  previousValues[pondId] = {
                        thresholds: pondData.device_config?.thresholds || null,
                        feeding_schedule: pondData.device_config?.feeding_schedule?.schedule || null,
                        aerator_delay: pondData.device_config?.aerator?.aerator_delay || null,
                        feeding_amount: pondData.device_config?.feeding_schedule?.amount || null,
                  };
            });
      }

      console.log("✅ Previous values initialized from Firebase.");
};

// 🔹 Panggil fungsi inisialisasi saat aplikasi dijalankan
initializePreviousValues();

const feedUpdateCache = {};

function displayName(key) {
      switch (key.toLowerCase()) {
            case "ph":
                  return "pH";
            case "salinity":
                  return "Salinitas";
            case "temperature":
                  return "Suhu";
            case "turbidity":
                  return "Kekeruhan";
            default:
                  return key.charAt(0).toUpperCase() + key.slice(1).toLowerCase();
      }
}


// 🔹 Pemantauan Firebase Realtime Database
db.ref("Sadewa_SmartFarm/ponds").on("child_changed", async (snapshot) => {
      const pondId = snapshot.key;
      const pondData = snapshot.val();
      if (!pondData) return;

      // 🔹 Ambil namePond dari MongoDB
      const kolam = await Kolam.model.findOne({
            idPond: pondId
      });
      const namePond = kolam ? kolam.namePond : pondId; // Jika tidak ditemukan, gunakan pondId

      console.log(`📡 Data Changed for ${namePond} (Pond ID: ${pondId})`);

      // 🔹 Notifikasi Perubahan Ambang Batas Sensor (threshold_update)
      if (pondData.device_config && pondData.device_config.thresholds) {
            const newThresholds = pondData.device_config.thresholds;
            const prevThresholds = previousValues[pondId].thresholds;

            if (prevThresholds && JSON.stringify(prevThresholds) !== JSON.stringify(newThresholds)) {
                  console.log(`🔧 Threshold updated for ${namePond}`);

                  const changes = [];
                  for (const key in newThresholds) {
                        const oldVal = prevThresholds[key];
                        const newVal = newThresholds[key];
                        if (JSON.stringify(oldVal) !== JSON.stringify(newVal)) {
                              changes.push(
                                    `${displayName(key)}: ${oldVal.low}–${oldVal.high} => ${newVal.low}–${newVal.high}`
                              );
                        }
                  }

                  await buatNotifikasi({
                        idPond: pondId,
                        type: "threshold_update",
                        title: "Perubahan Batas Parameter Sensor",
                        message: `Batas Parameter pada ${namePond} telah diubah :\n\n${changes.join(", ")}`,
                        time: new Date(),
                        status: "unread",
                        metadata: {
                              previous_thresholds: prevThresholds,
                              new_thresholds: newThresholds
                        }
                  });
            }

            // Perbarui nilai sebelumnya
            previousValues[pondId].thresholds = newThresholds;
      }

      // 🔹 Notifikasi Perubahan Jadwal & Jumlah Pakan (feed_schedule_update)
      if (pondData.device_config && pondData.device_config.feeding_schedule) {
            const newSchedule = pondData.device_config.feeding_schedule.schedule;
            const newAmount = pondData.device_config.feeding_schedule.amount;

            const prevSchedule = previousValues[pondId].feeding_schedule;
            const prevAmount = previousValues[pondId].feeding_amount;

            const scheduleChanged = prevSchedule && JSON.stringify(prevSchedule) !== JSON.stringify(newSchedule);
            const amountChanged = prevAmount !== undefined && prevAmount !== newAmount;

            if (scheduleChanged || amountChanged) {
                  // Jika sudah ada timeout sebelumnya, batalkan dulu
                  if (feedUpdateCache[pondId]?.timeout) {
                        clearTimeout(feedUpdateCache[pondId].timeout);
                  }

                  // Simpan perubahan ke cache
                  feedUpdateCache[pondId] = {
                        scheduleChanged,
                        amountChanged,
                        newSchedule,
                        newAmount,
                        prevSchedule,
                        prevAmount,
                        timeout: setTimeout(async () => {
                              const {
                                    scheduleChanged,
                                    amountChanged,
                                    newSchedule,
                                    newAmount,
                                    prevSchedule,
                                    prevAmount
                              } = feedUpdateCache[pondId];

                              let title = "Konfigurasi Pakan Diperbarui";
                              let message = `Konfigurasi pakan pada ${namePond} telah diperbarui:\n`;
                              const metadata = {};

                              if (scheduleChanged && amountChanged) {
                                    title = "Jadwal & Jumlah Pakan Diperbarui";
                                    message += `Jadwal: \n${prevSchedule?.join(", ")} \n => ${newSchedule.join(", ")}\n`;
                                    message += `Jumlah: \n${prevAmount} => ${newAmount} gram`;
                                    metadata.previous_schedule = prevSchedule;
                                    metadata.new_schedule = newSchedule;
                                    metadata.previous_amount = prevAmount;
                                    metadata.new_amount = newAmount;
                              } else if (scheduleChanged) {
                                    title = "Jadwal Pakan Diperbarui";
                                    message += `Jadwal: \n${prevSchedule?.join(", ")} \n => ${newSchedule.join(", ")}\n`;
                                    metadata.previous_schedule = prevSchedule;
                                    metadata.new_schedule = newSchedule;
                              } else if (amountChanged) {
                                    title = "Jumlah Pakan Diperbarui";
                                    message += `Jumlah: \n${prevAmount} => ${newAmount} gram`;
                                    metadata.previous_amount = prevAmount;
                                    metadata.new_amount = newAmount;
                              }

                              await buatNotifikasi({
                                    idPond: pondId,
                                    type: "feed_schedule_update",
                                    title,
                                    message: message.trim(),
                                    time: new Date(),
                                    status: "unread",
                                    metadata
                              });

                              // Update nilai sebelumnya
                              previousValues[pondId].feeding_schedule = newSchedule;
                              previousValues[pondId].feeding_amount = newAmount;

                              // Bersihkan cache
                              delete feedUpdateCache[pondId];
                        }, 1500) // Delay untuk hindari double-notif
                  };
            }
      }

      // 🔹 Notifikasi Perubahan Kontrol Aerator (aerator_control_update)
      if (pondData.device_config && pondData.device_config.aerator) {
            const newAerator = pondData.device_config.aerator.aerator_delay;
            const prevAerator = previousValues[pondId].aerator_delay;

            if (prevAerator !== undefined && newAerator !== undefined && prevAerator !== newAerator) {
                  console.log(`Aerator control updated for ${namePond}`);

                  const message = `Delay aerator untuk ${namePond} telah diubah dari ${prevAerator} menit => ${newAerator} menit`;

                  await buatNotifikasi({
                        idPond: pondId,
                        type: "aerator_control_update",
                        title: "Delay Aerator Diperbarui",
                        message,
                        time: new Date(),
                        status: "unread",
                        metadata: {
                              previous_aerator_control: prevAerator,
                              new_aerator_control: newAerator
                        },
                  });
            }

            // Perbarui nilai sebelumnya
            previousValues[pondId].aerator_delay = newAerator;
      }
});

const cron = require("node-cron");

// 🔁 Cek Feed Alert setiap 15 menit
cron.schedule("*/15 * * * *", async () => {
      console.log("🔁 [CRON] Mengecek kondisi feed_alert...");

      const pondsSnapshot = await db.ref("Sadewa_SmartFarm/ponds").once("value");
      const pondsData = pondsSnapshot.val();

      if (!pondsData) return;

      for (const pondId of Object.keys(pondsData)) {
            const pondData = pondsData[pondId];
            const kolam = await Kolam.model.findOne({
                  idPond: pondId
            });
            const namePond = kolam ? kolam.namePond : pondId;

            if (pondData.isi_pakan === true) {
                  console.log(`[CRON] Feed alert untuk ${namePond}`);

                  await buatNotifikasi({
                        idPond: pondId,
                        type: "feed_alert",
                        title: "Pakan Hampir Habis",
                        message: `Pakan udang pada ${namePond} hampir habis, harap untuk segera mengisi ulang pakan sebelum waktu pemberian pakan.`,
                        time: new Date(),
                        status: "unread",
                        metadata: {
                              isi_pakan: true
                        }
                  });
            }
      }
});

// 🔁 Cek Water Quality setiap 1 menit
cron.schedule("* * * * *", async () => {
      console.log("🔁 [CRON] Mengecek kualitas air...");

      const pondsSnapshot = await db.ref("Sadewa_SmartFarm/ponds").once("value");
      const pondsData = pondsSnapshot.val();

      if (!pondsData) return;

      for (const pondId of Object.keys(pondsData)) {
            const pondData = pondsData[pondId];
            const kolam = await Kolam.model.findOne({
                  idPond: pondId
            });
            const namePond = kolam ? kolam.namePond : pondId;

            if (pondData.sensor_data && pondData.device_config?.thresholds) {
                  const {
                        ph,
                        salinity,
                        temperature,
                        turbidity
                  } = pondData.sensor_data;

                  const {
                        thresholds
                  } = pondData.device_config;

                  const alerts = [];
                  if (ph < thresholds.ph.low || ph > thresholds.ph.high) alerts.push("pH");
                  if (salinity < thresholds.salinity.low || salinity > thresholds.salinity.high) alerts.push("Salinitas");
                  if (temperature < thresholds.temperature.low || temperature > thresholds.temperature.high) alerts.push("Suhu");
                  if (turbidity < thresholds.turbidity.low || turbidity > thresholds.turbidity.high) alerts.push("Kekeruhan");

                  if (alerts.length > 0 && !(await isDuplicateNotification(pondId, "water_quality_alert"))) {
                        console.log(`🚨 [CRON] Water quality alert untuk ${namePond}: ${alerts.join(", ")}`);

                        const alertDetails = alerts.map((param) => {
                              switch (param) {
                                    case "pH":
                                          return `pH = ${ph}`;
                                    case "Salinitas":
                                          return `Salinitas = ${salinity} PPT`;
                                    case "Suhu":
                                          return `Suhu = ${temperature}°C`;
                                    case "Kekeruhan":
                                          return `Kekeruhan = ${turbidity} NTU`;
                                    default:
                                          return param;
                              }
                        });

                        await buatNotifikasi({
                              idPond: pondId,
                              type: "water_quality_alert",
                              title: "Kualitas Air",
                              message: `Kualitas ${alerts.join(", ")} air pada ${namePond} berada di luar batas normal.\nNilai ${alertDetails.join(", ")}`,
                              time: new Date(),
                              status: "unread",
                              metadata: {
                                    alerts,
                                    sensor_values: {
                                          ph,
                                          salinity,
                                          temperature,
                                          turbidity
                                    },
                              },
                        });
                  }
            }
      }
});


console.log("🔄 Firebase notification listener aktif...");