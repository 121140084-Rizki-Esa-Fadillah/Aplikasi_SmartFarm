const express = require("express");
const { checkUserExistence, checkKolamExistence } = require("../services/checkData");

const router = express.Router();

router.post("/user", async (req, res) => {
    const { username, email } = req.body;

    if (!username || !email) {
        return res.status(400).json({ message: "Username dan email harus diisi" });
    }

    try {
        const result = await checkUserExistence(username, email);
        res.json(result);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server error" });
    }
});

router.post("/kolam", async (req, res) => {
    const { idPond, namePond } = req.body;

    if (!idPond || !namePond) {
        return res.status(400).json({ message: "idPond dan namePond harus diisi" });
    }

    try {
        const result = await checkKolamExistence(idPond, namePond);
        res.json(result);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server error" });
    }
});

module.exports = router;
