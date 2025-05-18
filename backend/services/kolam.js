const Kolam = require("../models/kolam");

const ambilDataKolam = async () => {
      try {
            const kolam = await Kolam.ambilDataKolam();
            return {
                  status: 200,
                  success: true,
                  data: kolam,
            };
      } catch (error) {
            return {
                  status: 500,
                  success: false,
                  message: error.message,
            };
      }
};

const tambahKolam = async (data) => {
      try {
            const kolam = await Kolam.tambahKolam(data);
            return {
                  status: 201,
                  success: true,
                  message: "Kolam berhasil ditambahkan",
                  data: kolam,
            };
      } catch (error) {
            return {
                  status: 500,
                  success: false,
                  message: error.message,
            };
      }
};

const editKolam = async (id, data) => {
      try {
            const kolam = await Kolam.editKolam(id, data);
            if (!kolam) {
                  return {
                        status: 404,
                        success: false,
                        message: "Kolam tidak ditemukan",
                  };
            }
            return {
                  status: 200,
                  success: true,
                  message: "Kolam berhasil diperbarui",
                  data: kolam,
            };
      } catch (error) {
            return {
                  status: 500,
                  success: false,
                  message: error.message,
            };
      }
};

const hapusKolam = async (id) => {
      try {
            const kolam = await Kolam.hapusKolam(id);
            if (!kolam) {
                  return {
                        status: 404,
                        success: false,
                        message: "Kolam tidak ditemukan",
                  };
            }
            return {
                  status: 200,
                  success: true,
                  message: "Kolam berhasil dihapus",
            };
      } catch (error) {
            return {
                  status: 500,
                  success: false,
                  message: error.message,
            };
      }
};

module.exports = {
      ambilDataKolam,
      tambahKolam,
      editKolam,
      hapusKolam
};