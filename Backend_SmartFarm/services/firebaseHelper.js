const {
      db
} = require("../config/firebaseConfig");

// Ambil data sensor berdasarkan pondId
const getMonitoringData = async (pondId) => {
      try {
            const firebasePath = `App_SmartFarm/ponds/${pondId}/sensor_data`;
            const snapshot = await db.ref(firebasePath).once("value");
            if (!snapshot.exists()) {
                  throw new Error(`Data sensor untuk pondId ${pondId} tidak ditemukan.`);
            }
            // Mengembalikan data yang ditemukan
            return snapshot.val();
      } catch (error) {
            throw new Error(`Gagal mengambil data sensor: ${error.message}`);
      }
};

// Ambil konfigurasi device
const getDeviceConfig = async (pondId, keyPath = "") => {
      try {
            let fullPath = `App_SmartFarm/ponds/${pondId}/device_config`;
            if (keyPath) {
                  fullPath += `/${keyPath.replace(/^\/*|\/*$/g, '')}`;
            }

            const snapshot = await db.ref().child(fullPath).once("value");
            if (!snapshot.exists()) {
                  throw new Error(`Data tidak ditemukan di path: ${fullPath}`);
            }

            return snapshot.val();
      } catch (error) {
            throw new Error(`Gagal mengambil data: ${error.message}`);
      }
};

// Update konfigurasi device
const updateDeviceConfig = async (pondId, keyPath, newValue) => {
      try {
            if (!keyPath) {
                  throw new Error("Path konfigurasi harus ditentukan.");
            }

            let updatePath = `App_SmartFarm/ponds/${pondId}/device_config/${keyPath.replace(/^\/|\/$/g, '')}`;

            if (typeof newValue === 'number' || typeof newValue === 'string') {
                  await db.ref().child(updatePath).set(Number(newValue));
            } else if (typeof newValue === 'object' && newValue !== null) {
                  await db.ref().child(updatePath).update(newValue);
            } else {
                  throw new Error("Format data tidak valid.");
            }

            return {
                  message: `Berhasil memperbarui ${keyPath}`
            };
      } catch (error) {
            throw new Error(`Gagal memperbarui data: ${error.message}`);
      }
};

module.exports = {
      getMonitoringData,
      getDeviceConfig,
      updateDeviceConfig
};