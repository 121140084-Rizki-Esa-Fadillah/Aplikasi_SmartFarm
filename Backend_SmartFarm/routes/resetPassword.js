const express = require("express");
const dotenv = require("dotenv");
const path = require("path");
const {
	resetPassword
} = require("../services/resetPassword");

dotenv.config({
	path: path.resolve(__dirname, "../.env")
});

const router = express.Router();

router.post("/reset-password", async (req, res) => {
	const {
		token,
		newPassword
	} = req.body;

	try {
		const result = await resetPassword(token, newPassword);
		res.json(result);
	} catch (error) {
		res.status(400).json({
			message: error.message
		});
	}
});

module.exports = router;