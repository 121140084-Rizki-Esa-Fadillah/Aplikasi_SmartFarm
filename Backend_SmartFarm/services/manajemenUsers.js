const mongoose = require("mongoose");
const User = require("../models/user");

const ambilDataUser = async () => {
      return await User.model.find({}, "id username email role createdAt");
};

const hapusUserById = async (id) => {
      if (!mongoose.Types.ObjectId.isValid(id)) {
            throw new Error("ID tidak valid");
      }

      const user = await User.model.findById(id);
      if (!user) {
            throw new Error("User tidak ditemukan");
      }

      console.log(`Menghapus user: ${user.username}`);
      await User.model.findByIdAndDelete(id);
      return user.username;
};

const editUserById = async (id, {
      username,
      email,
      role
}) => {
      if (!mongoose.Types.ObjectId.isValid(id)) {
            throw new Error("ID tidak valid");
      }

      const user = await User.model.findById(id);
      if (!user) {
            throw new Error("User tidak ditemukan");
      }

      user.username = username;
      user.email = email;
      user.role = role;
      await user.save();

      console.log(`User ${user.username} berhasil diperbarui`);
      return user;
};

const buatUser = async ({
      username,
      email,
      password,
      role
}) => {
      if (!username || !email || !password || !role) {
            throw new Error("Semua field harus diisi!");
      }

      const existingUser = await User.model.findOne({
            email
      });
      if (existingUser) {
            throw new Error("Email sudah digunakan!");
      }

      const newUser = new User.model({
            username,
            email,
            password,
            role
      });

      await newUser.save();

      return newUser;
};

module.exports = {
      ambilDataUser,
      hapusUserById,
      editUserById,
      buatUser
};