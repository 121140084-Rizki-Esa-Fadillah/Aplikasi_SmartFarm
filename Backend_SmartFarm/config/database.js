const mongoose = require("mongoose");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config({
    path: path.resolve(__dirname, "../.env")
});

if (!process.env.MONGO_URI) {
    console.error("ERROR: MONGO_URI tidak ditemukan! Pastikan file .env sudah diisi dengan benar.");
    process.exit(1);
}

async function connectDB() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("Koneksi MongoDB Berhasil!");
    } catch (error) {
        console.error("Gagal koneksi ke MongoDB:", error);
        process.exit(1);
    }
}

async function disconnectDB() {
    try {
        await mongoose.disconnect();
        console.log("Koneksi MongoDB Terputus!");
    } catch (error) {
        console.error("Gagal memutuskan koneksi MongoDB:", error);
    }
}

module.exports = {
    connectDB,
    disconnectDB
};