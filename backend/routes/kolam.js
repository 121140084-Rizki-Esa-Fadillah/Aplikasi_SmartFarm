const express = require("express");
const {
      ambilDataKolam,
      tambahKolam,
      editKolam,
      hapusKolam
} = require("../services/kolam");
const {
      verifyToken,
      isAdmin
} = require("../middleware/auth");

const router = express.Router();

// ✅ Ambil semua kolam
router.get("/kolam", verifyToken, async (req, res) => {
      try {
            const response = await ambilDataKolam();
            res.status(response.status).json(response);
      } catch (error) {
            res.status(500).json({
                  message: "Gagal mengambil data kolam."
            });
      }
});

// ✅ Tambah kolam
router.post("/kolam", verifyToken, isAdmin, async (req, res) => {
      const {
            idPond,
            namePond
      } = req.body;
      try {
            const response = await tambahKolam({
                  idPond,
                  namePond,
                  statusPond: "Aktif"
            });
            res.status(response.status).json(response);
      } catch (error) {
            res.status(500).json({
                  message: "Gagal menambahkan kolam."
            });
      }
});

// ✅ Update kolam
router.put("/kolam/:id", verifyToken, isAdmin, async (req, res) => {
      const {
            pond_id,
            name,
            status
      } = req.body;
      const kolamId = req.params.id;

      try {
            const response = await editKolam(kolamId, {
                  idPond: pond_id,
                  namePond: name,
                  statusPond: status
            });

            res.status(response.status).json(response);
      } catch (error) {
            console.error("❌ Error updating kolam:", error);
            res.status(500).json({
                  message: "Terjadi kesalahan server."
            });
      }
});

// ✅ Hapus kolam
router.delete("/kolam/:id", verifyToken, isAdmin, async (req, res) => {
      try {
            const response = await hapusKolam(req.params.id);
            res.status(response.status).json(response);
      } catch (error) {
            res.status(500).json({
                  message: "Gagal menghapus kolam."
            });
      }
});

module.exports = router;