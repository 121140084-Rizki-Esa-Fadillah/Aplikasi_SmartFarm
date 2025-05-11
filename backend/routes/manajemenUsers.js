const express = require("express");
const {
	verifyToken,
	isAdmin
} = require("../middleware/auth");
const {
	ambilDataUser,
      hapusUserById,
      editUserById,
      buatUser
} = require("../services/manajemenUsers");

const router = express.Router();

// ✅ Get semua user
router.get("/manajemenUsers", verifyToken, async (req, res) => {
	try {
		const users = await ambilDataUser();
		res.json(users);
	} catch (error) {
		res.status(500).json({
			message: "Server error",
			error: error.message
		});
	}
});

// ✅ Hapus user berdasarkan ID
router.delete("/manajemenUsers/:id", verifyToken, isAdmin, async (req, res) => {
	try {
		const username = await hapusUserById(req.params.id);
		res.json({
			message: `User ${username} berhasil dihapus`
		});
	} catch (error) {
		res.status(400).json({
			message: error.message
		});
	}
});

// ✅ Edit user berdasarkan ID
router.put("/manajemenUsers/:id", verifyToken, isAdmin, async (req, res) => {
	try {
		const {
			username,
			email,
			role
		} = req.body;

		if (!username || !email || !role) {
			return res.status(400).json({
				message: "Semua field harus diisi"
			});
		}

		const updatedUser = await editUserById(req.params.id, {
			username,
			email,
			role
		});
		res.status(200).json({
			message: "User berhasil diperbarui",
			user: updatedUser
		});
	} catch (error) {
		res.status(400).json({
			message: error.message
		});
	}
});

// ✅ Tambah user baru
router.post("/manajemenUsers", async (req, res) => {
	try {
		const newUser = await buatUser(req.body);
		res.status(201).json({
			message: "User berhasil ditambahkan!",
			user: newUser
		});
	} catch (error) {
		res.status(400).json({
			message: error.message
		});
	}
});

module.exports = router;