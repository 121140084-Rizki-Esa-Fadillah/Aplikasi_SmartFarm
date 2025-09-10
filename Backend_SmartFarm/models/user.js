const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

class User {
      constructor() {
            const userSchema = new mongoose.Schema({
                  username: {
                        type: String,
                        required: true,
                        unique: true,
                        trim: true
                  },
                  email: {
                        type: String,
                        required: true,
                        unique: true,
                        lowercase: true,
                        trim: true,
                        match: [/^\S+@\S+\.\S+$/, "Format email tidak valid"]
                  },
                  password: {
                        type: String,
                        required: true
                  },
                  role: {
                        type: String,
                        enum: ["Admin", "User"],
                        default: "User"
                  },
                  createdAt: {
                        type: Date,
                        default: Date.now
                  },
                  deviceToken: {
                        type: String,
                        default: ""
                  }
            });

            userSchema.pre("save", async function (next) {
                  if (!this.isModified("password")) return next();
                  try {
                        const salt = await bcrypt.genSalt(10);
                        this.password = await bcrypt.hash(this.password, salt);
                        next();
                  } catch (err) {
                        next(err);
                  }
            });

            this.User = mongoose.model("User", userSchema);
      }

      async login(username, password, deviceToken, jwt, secretKey) {
            const user = await this.User.findOne({
                  username
            });
            if (!user) throw new Error("User tidak ditemukan!");

            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) throw new Error("Password salah!");

            if (!deviceToken) throw new Error("Device token tidak ditemukan!");

            const token = jwt.sign({
                  id: user._id,
                  username: user.username,
                  role: user.role
            }, secretKey, {
                  expiresIn: "6h"
            });

            user.deviceToken = deviceToken;
            await user.save();

            return {
                  message: "Login berhasil!",
                  token,
                  role: user.role, 
            };
      }

      async logout(userId) {
            const user = await this.User.findById(userId);
            if (!user) throw new Error("User tidak ditemukan!");

            return {
                  message: "Logout berhasil!"
            };
      }

      get model() {
            return this.User;
      }
}

module.exports = new User();