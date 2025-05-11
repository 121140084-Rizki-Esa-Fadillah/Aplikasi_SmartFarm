const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const User = require("../models/user");

const SECRET_KEY = process.env.JWT_SECRET;

const resetPassword = async (token, newPassword) => {
	try {
		console.log("🔹 Memproses reset password...");
		console.log("📩 Token:", token);
		console.log("🔑 Password Baru:", newPassword);

		// Verifikasi token JWT
		const decoded = jwt.verify(token, SECRET_KEY);
		console.log("✅ Token berhasil diverifikasi:", decoded);

		// Cek apakah user ada di database
		const user = await User.model.findOne({ email: decoded.email });
		if (!user) {
			console.log("❌ User tidak ditemukan!");
			throw new Error("User tidak ditemukan!");
		}

		// Set password baru tanpa hashing ulang
		user.password = newPassword;

		// Simpan perubahan (akan otomatis di-hash oleh model)
		await user.save();
		console.log("✅ Password berhasil diperbarui untuk:", user.email);

		return {
			message: "Password berhasil direset!"
		};
	} catch (error) {
		console.error("❌ Error saat reset password:", error.message);
		throw new Error("Token tidak valid atau sudah kadaluarsa!");
	}
};

module.exports = {
	resetPassword
};