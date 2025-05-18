const express = require("express");
const {
      login,
      logout
} = require("../services/auth");

const router = express.Router();

router.post("/login", async (req, res) => {
      const {
            username,
            password,
            deviceToken
      } = req.body;

      try {
            const result = await login(username, password, deviceToken);
            res.json(result);
      } catch (error) {
            res.status(400).json({
                  message: error.message
            });
      }
});

router.post("/logout", async (req, res) => {
      const authHeader = req.headers.authorization;
      const token = authHeader && authHeader.split(" ")[1];

      if (!token) {
            return res.status(400).json({
                  message: "Token tidak ditemukan!"
            });
      }

      try {
            const result = await logout(token);
            res.json(result);
      } catch (error) {
            res.status(400).json({
                  message: error.message
            });
      }
});

module.exports = router;