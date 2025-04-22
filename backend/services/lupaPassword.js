const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const nodemailer = require("nodemailer");
const dotenv = require("dotenv");
const jwt = require("jsonwebtoken");
const User = require("../models/users");

dotenv.config({
	path: path.resolve(__dirname, "../.env")
});

const SECRET_KEY = process.env.JWT_SECRET;
const OTP_EXPIRATION = 5 * 60 * 1000; // 5 menit

const otpStorage = {};

// Konfigurasi Nodemailer
const transporter = nodemailer.createTransport({
	host: process.env.EMAIL_HOST,
	port: process.env.EMAIL_PORT,
	secure: true,
	auth: {
		user: process.env.EMAIL_USER,
		pass: process.env.EMAIL_PASS,
	},
	tls: {
		rejectUnauthorized: false,
	},
});

// Fungsi membaca dan mengganti variabel dalam template email
const getEmailTemplate = (username, otp) => {
	const templatePath = path.resolve(__dirname, "..", "templates", "email_template.html");

	if (!fs.existsSync(templatePath)) {
		throw new Error(`Template email tidak ditemukan di: ${templatePath}`);
	}

	let template = fs.readFileSync(templatePath, "utf8");
	template = template.replace("{{username}}", username).replace("{{otp}}", otp);
	return template;
};

// Kirim OTP menggunakan email template
const sendOTP = async (email) => {
	const user = await User.findOne({
		email
	});
	if (!user) {
		throw new Error("Email tidak ditemukan!");
	}

	const otp = crypto.randomInt(1000, 9999).toString();
	otpStorage[email] = {
		otp,
		expiresAt: Date.now() + OTP_EXPIRATION
	};

	// Gunakan username, jika tidak ada gunakan "Pengguna"
	const username = user.username || "Pengguna";
	const htmlContent = getEmailTemplate(username, otp);

	const mailOptions = {
		from: `"Tambak Udang Sadewa Farm" <${process.env.EMAIL_USER}>`,
		to: email,
		subject: "Kode OTP Reset Password",
		html: htmlContent, // Gunakan template HTML
	};

	try {
		await transporter.sendMail(mailOptions);
		return "Kode OTP telah dikirim ke email Anda!";
	} catch (error) {
		console.error("Error saat mengirim email:", error);
		throw new Error("Gagal mengirim OTP. Periksa kredensial email!");
	}
};

// Verifikasi OTP
const verifyOTP = (email, otp) => {
	if (!otpStorage[email]) {
		throw new Error("Kode OTP tidak valid!");
	}

	if (otpStorage[email].expiresAt < Date.now()) {
		delete otpStorage[email]; // Hapus OTP yang kedaluwarsa
		return "expired"; // Mengembalikan string "expired" ke frontend
	}

	if (otpStorage[email].otp !== otp) {
		throw new Error("Kode OTP salah!");
	}

	delete otpStorage[email];
	const token = jwt.sign({
		email
	}, SECRET_KEY, {
		expiresIn: "5m"
	});

	return token;
};


module.exports = {
	sendOTP,
	verifyOTP
};