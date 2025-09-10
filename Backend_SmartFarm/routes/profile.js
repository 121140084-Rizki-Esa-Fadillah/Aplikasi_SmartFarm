const express = require("express");
const {
	ambilDataProfile,
      editDataProfile
} = require("../services/profile");

const router = express.Router();

router.get("/profile", async (req, res) => {
	try {
		const authHeader = req.headers.authorization;
		const token = authHeader && authHeader.split(" ")[1];

		const user = await ambilDataProfile(token);
		res.json(user);
	} catch (error) {
		res.status(401).json({
			message: error.message
		});
	}
});

router.put("/profile", async (req, res) => {
	try {
		const authHeader = req.headers.authorization;
		const token = authHeader && authHeader.split(" ")[1];

		const {
			username,
			email
		} = req.body;
		const result = await editDataProfile(token, {
			username,
			email
		});
		res.json(result);
	} catch (error) {
		res.status(401).json({
			message: error.message
		});
	}
});

module.exports = router;