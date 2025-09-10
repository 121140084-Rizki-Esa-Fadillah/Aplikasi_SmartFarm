const express = require("express");
const {
	kirimOTP,
	verifikasiOTP
} = require("../services/lupaPassword");

const router = express.Router();

router.post("/send-otp", async (req, res) => {
	const {
		email
	} = req.body;
	try {
		const message = await kirimOTP(email);
		res.json({
			message
		});
	} catch (error) {
		res.status(400).json({
			message: error.message
		});
	}
});

router.post("/verify-otp", (req, res) => {
	const {
		email,
		otp
	} = req.body;
	try {
		const result = verifikasiOTP(email, otp);

		if (result === "expired") {
			return res.status(401).json({
				message: "expired"
			}); 
		}

		res.json({
			message: "OTP valid, lanjutkan reset password!",
			token: result
		});
	} catch (error) {
		res.status(400).json({
			message: error.message
		});
	}
});


module.exports = router;