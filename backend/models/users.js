// models/users.js
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const UserSchema = new mongoose.Schema({
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
            enum: ["Admin", "User"], // Pastikan default role sesuai kapitalisasi
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

// 🔹 Middleware: Hash password sebelum disimpan atau diubah
UserSchema.pre("save", async function (next) {
      if (!this.isModified("password")) return next();

      try {
            const salt = await bcrypt.genSalt(10);
            this.password = await bcrypt.hash(this.password, salt);
            next();
      } catch (error) {
            next(error);
      }
});

module.exports = mongoose.model("User", UserSchema);