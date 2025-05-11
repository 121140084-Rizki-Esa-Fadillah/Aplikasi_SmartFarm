const User = require("../models/user");
const jwt = require("jsonwebtoken");

const SECRET_KEY = process.env.JWT_SECRET;

const ambilDataProfile = async (token) => {
      if (!token) throw new Error("Unauthorized");

      const decoded = jwt.verify(token, SECRET_KEY);
      const user = await User.model.findById(decoded.id).select("-password");

      if (!user) throw new Error("User tidak ditemukan");

      return user;
};

const editDataProfile = async (token, {
      username,
      email
}) => {
      if (!token) throw new Error("Unauthorized");

      const decoded = jwt.verify(token, SECRET_KEY);
      const user = await User.model.findById(decoded.id);

      if (!user) throw new Error("User tidak ditemukan");

      user.username = username || user.username;
      user.email = email || user.email;
      await user.save();

      return {
            message: "Profil berhasil diperbarui",
            user,
      };
};

module.exports = {
      ambilDataProfile,
      editDataProfile
};