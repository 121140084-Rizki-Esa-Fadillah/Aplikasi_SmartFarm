const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const User = require("../models/users");
const admin = require("firebase-admin");
const dotenv = require("dotenv");
dotenv.config();

const SECRET_KEY = process.env.JWT_SECRET;

const AuthService = {
      // ✅ Login User
      login: async (username, password, deviceToken) => {
            const user = await User.findOne({
                  username
            });
            if (!user) throw new Error("User tidak ditemukan!");

            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) throw new Error("Password salah!");

            const token = jwt.sign({
                  id: user._id,
                  username: user.username,
                  role: user.role
            }, SECRET_KEY, {
                  expiresIn: "1h"
            });

            if (!deviceToken) throw new Error("Device token tidak ditemukan!");

            user.deviceToken = deviceToken;
            await user.save();

            return {
                  message: "Login berhasil!",
                  token
            };
      },

      // ✅ Logout User (Frontend menghapus token)
      logout: async (userId) => {
            const user = await User.findById(userId);
            if (!user) throw new Error("User tidak ditemukan!");

            user.deviceToken = null;
            await user.save();

            return {
                  message: "Logout berhasil!"
            };
      }
};

module.exports = AuthService;