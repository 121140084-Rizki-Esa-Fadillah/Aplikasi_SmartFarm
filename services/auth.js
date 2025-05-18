const jwt = require("jsonwebtoken");
const dotenv = require("dotenv");
const User = require("../models/user");

dotenv.config();
const SECRET_KEY = process.env.JWT_SECRET;

const login = async (username, password, deviceToken) => {
      return await User.login(username, password, deviceToken, jwt, SECRET_KEY);
};

const logout = async (token) => {
      try {
            const decoded = jwt.verify(token, SECRET_KEY);
            return await User.logout(decoded.id);
      } catch (err) {
            throw new Error("Token tidak valid!");
      }
};

module.exports = {
      login,
      logout
};