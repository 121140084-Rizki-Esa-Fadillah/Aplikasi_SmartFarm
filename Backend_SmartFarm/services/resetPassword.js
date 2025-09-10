const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const User = require("../models/user");

const SECRET_KEY = process.env.JWT_SECRET;

const resetPassword = async (token, newPassword) => {
	try {
		console.log(" Memproses reset password...");
		console.log("Token:", token);
		console.log(" Password Baru:", newPassword);

		// Verifikasi token JWT
		const decoded = jwt.verify(token, SECRET_KEY);

		const user = await User.model.findOne({ email: decoded.email });
		if (!user) {
			throw new Error("User tidak ditemukan!");
		}

		user.password = newPassword;
		await user.save();

		return {
			message: "Password berhasil direset!"
		};
	} catch (error) {
		throw new Error("Token tidak valid atau sudah kadaluarsa!");
	}
};

module.exports = {
	resetPassword
};