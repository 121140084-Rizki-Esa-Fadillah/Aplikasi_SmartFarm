const express = require("express");
const {
      verifyToken
} = require("../middleware/auth");
const {
      buatNotifikasi,
      ambilNotifikasiById,
      ambilNotifikasiByPond,
      tandaiNotifikasi
} = require("../services/notifikasi");

const router = express.Router();

// ✅ Ambil notifikasi berdasarkan ID
router.get("/:id", verifyToken, async (req, res) => {
      try {
            const notification = await ambilNotifikasiById(req.params.id);
            if (!notification) {
                  return res.status(404).json({
                        error: "Notifikasi tidak ditemukan"
                  });
            }
            res.status(200).json(notification);
      } catch (error) {
            res.status(500).json({
                  error: "Gagal mengambil notifikasi",
                  details: error.message
            });
      }
});

// ✅ Ambil notifikasi berdasarkan idPond
router.get("/pond/:idPond", verifyToken, async (req, res) => {
      try {
            const notifications = await ambilNotifikasiByPond(req.params.idPond);
            if (!notifications || !notifications.length) {
                  return res.status(404).json({
                        error: "Tidak ada notifikasi ditemukan"
                  });
            }
            res.status(200).json(notifications);
      } catch (error) {
            res.status(500).json({
                  error: "Gagal mengambil notifikasi",
                  details: error.message
            });
      }
});

// ✅ Tandai notifikasi sebagai dibaca
router.patch("/:id/read", verifyToken, async (req, res) => {
      try {
            const updated = await tandaiNotifikasi(req.params.id);
            if (!updated) {
                  return res.status(404).json({
                        error: "Notifikasi tidak ditemukan"
                  });
            }
            res.status(200).json({
                  message: "✅ Notifikasi berhasil ditandai sebagai dibaca",
                  notification: updated
            });
      } catch (error) {
            res.status(500).json({
                  error: "Gagal memperbarui notifikasi",
                  details: error.message
            });
      }
});

module.exports = router;