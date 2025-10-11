const express = require("express");
const router = express.Router();
const { simpanHistory, hapusHistory, collectDataFromFirebase} = require("../services/history");
const { hapusNotifikasi } = require("../services/notifikasi");

router.get("/run-daily-tasks", async (req, res) => {
  try {
    console.log("Endpoint cron run-daily-tasks dipanggil oleh cron-job.org");
    await simpanHistory();
    await hapusHistory();
    await hapusNotifikasi();
    res.status(200).send("Cron job executed successfully.");
  } catch (error) {
    console.error("Gagal menjalankan cron job:", error);
    res.status(500).send("Internal server error.");
  }
});

module.exports = router;

router.get("/collect-data", async (req, res) => {
  try {
    console.log("Mengambil data setiap 15 menit...");
    await collectDataFromFirebase();
    res.status(200).send("Cron job executed successfully.");
  } catch (error) {
    console.error("Gagal menjalankan cron job:", error);
    res.status(500).send("Internal server error.");
  }
});

module.exports = router;
