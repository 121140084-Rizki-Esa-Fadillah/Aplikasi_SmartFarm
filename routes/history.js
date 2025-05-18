const express = require("express");
const {
	ambilHistoryByPond,
	ambilHistoryById,
} = require("../services/history");

const router = express.Router();

router.get("/history/pond", async (req, res) => {
	try {
		const {
			idPond
		} = req.query;

		if (!idPond) {
			return res.status(400).json({
				message: "idPond diperlukan!"
			});
		}

		const history = await ambilHistoryByPond(idPond);

		if (!history || history.length === 0) {
			return res.status(404).json({
				message: "Riwayat tidak ditemukan!"
			});
		}

		res.status(200).json(history);
	} catch (error) {
		console.error("Error saat mengambil riwayat:", error.message);
		res.status(500).json({
			message: "Server error",
			error: error.message
		});
	}
});

router.get("/history/id", async (req, res) => {
	try {
		const {
			id
		} = req.query;

		if (!id) {
			return res.status(400).json({
				message: "ID riwayat diperlukan!"
			});
		}

		const history = await ambilHistoryById(id);

		if (!history) {
			return res.status(404).json({
				message: "Riwayat tidak ditemukan!"
			});
		}

		res.status(200).json(history);
	} catch (error) {
		console.error("Error saat mengambil riwayat:", error.message);
		res.status(500).json({
			message: "Server error",
			error: error.message
		});
	}
});

module.exports = router;