const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const path = require("path");
const helmet = require("helmet");
const {
	connectDB
} = require("./config/database");

dotenv.config();

const app = express();

// Middleware
app.use(express.urlencoded({
	extended: true
}));
app.use(express.json({
	strict: false
}));
app.use(cors());
app.use(helmet());

//  Koneksi Database
connectDB();

// Cron Job History
require("./services/history");
require("./services/notifikasi");
require("./services/notificationListener");

// Routes
const authRoutes = require("./routes/auth");
const lupaPasswordRoutes = require("./routes/lupaPassword");
const resetPasswordRoutes = require("./routes/resetPassword");
const profileRoutes = require("./routes/profile");
const manajemenUserRoutes = require("./routes/manajemenUsers");
const manajemenKolamRoutes = require("./routes/kolam");
const historyRoutes = require("./routes/history");
const notificationRoutes = require("./routes/notifikasi");
const monitoringRoutes = require("./routes/monitoring");
const aeratorRoutes = require("./routes/aerator");
const feederRoutes = require("./routes/feeder");
const thresholdRoutes = require("./routes/thresholds");
const checkDataRouter = require("./routes/checkData");
const emailCheckRoute = require('./routes/checkEmail');
const cronRoutes = require("./routes/cron");

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/password", lupaPasswordRoutes);
app.use("/api/password", resetPasswordRoutes);
app.use("/api/users", profileRoutes);
app.use("/api/users", manajemenUserRoutes);
app.use("/api", manajemenKolamRoutes);
app.use("/api", historyRoutes);
app.use("/api/notifikasi", notificationRoutes);
app.use("/api/monitoring", monitoringRoutes);
app.use("/api/konfigurasi/aerator", aeratorRoutes);
app.use("/api/konfigurasi/feeding", feederRoutes);
app.use("/api/konfigurasi/thresholds", thresholdRoutes);
app.use("/api/check", checkDataRouter);
app.use('/api', emailCheckRoute);
app.use("/api/cron", cronRoutes);

// Jalankan Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
	console.log("====================================");
	console.log(`Server berjalan di port ${PORT}`);
	console.log("Cron Jobs untuk History & Notifikasi Aktif ");
	console.log("====================================");
});