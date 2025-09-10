const {
	DateTime
} = require("luxon");
const {
	db
} = require("../config/firebaseConfig");
const History = require("../models/history");
const cron = require("node-cron");

const dailyHistoryBuffer = {};

const ambilHistoryByPond = async (idPond) => {
	try {
		const history = await History.ambilHistoryByPond(idPond);
		return history.length > 0 ? history : null;
	} catch (error) {
		throw new Error("Gagal mengambil riwayat:", error.message);
	}
};

const ambilHistoryById = async (id) => {
	try {
		const history = await History.ambilHistoryById(id);
		return history || null;
	} catch (error) {
		throw new Error("Gagal mengambil riwayat berdasarkan ID:", error.message);
	}
};

const collectDataFromFirebase = async () => {
	try {
		console.log("Mengambil data monitoring dari Firebase...");

		const ref = db.ref("Sadewa_SmartFarm/ponds");
		const snapshot = await ref.once("value");
		const pondsData = snapshot.val();

		if (!pondsData) {
			console.log("Tidak ada data kolam ditemukan.");
			return;
		}

		// Pakai Luxon, set timezone ke Asia/Jakarta
		const now = DateTime.now().setZone("Asia/Jakarta");
		const time = now.toFormat("HH:mm:ss");
		const date = now.toISODate(); // format YYYY-MM-DD

		for (const pondId in pondsData) {
			const pond = pondsData[pondId];
			if (!pond.sensor_data) continue;

			const {
				temperature,
				ph,
				salinity,
				turbidity,
				rain_status
			} = pond.sensor_data;

			const historyData = {
				time,
				temperature,
				ph,
				salinity,
				turbidity,
				rain_status,
			};

			if (!dailyHistoryBuffer[pondId]) dailyHistoryBuffer[pondId] = {};
			if (!dailyHistoryBuffer[pondId][date]) dailyHistoryBuffer[pondId][date] = [];

			dailyHistoryBuffer[pondId][date].push(historyData);
			console.log(`Data ditambahkan ke buffer untuk ${pondId} pada ${time}`);
		}
	} catch (error) {
		console.error("Gagal mengambil data dari Firebase:", error.message);
	}
};

const simpanHistory = async () => {
	try {
		console.log("Menyimpan laporan harian ke database...");

		// Simpan juga dengan timezone Asia/Jakarta
		const date = DateTime.now().setZone("Asia/Jakarta").toISODate();

		for (const pondId in dailyHistoryBuffer) {
			if (!dailyHistoryBuffer[pondId][date]) continue;

			try {
				await History.simpanHistory(pondId, date, dailyHistoryBuffer[pondId][date]);
				console.log(`Laporan harian untuk ${pondId} pada ${date} berhasil disimpan.`);
			} catch (error) {
				console.log(`Tidak dapat menyimpan laporan untuk ${pondId}: ${error.message}`);
			}
		}
		for (const pondId in dailyHistoryBuffer) {
			delete dailyHistoryBuffer[pondId][date];
		}

	} catch (error) {
		console.error("Gagal menyimpan laporan harian:", error.message);
	}
};

const hapusHistory = async () => {
	try {
		const now = DateTime.now().setZone("Asia/Jakarta");
		const oneMonthAgo = now.minus({
			months: 1
		});

		console.log(`Menghapus riwayat sebelum: ${oneMonthAgo.toISO()}`);

		const result = await History.hapusHistory(oneMonthAgo.toJSDate());
		console.log(`Riwayat lama yang dihapus: ${result.deletedCount}`);
	} catch (error) {
		console.error("Gagal menghapus riwayat lama:", error.message);
	}
};

// Jadwal Cron
cron.schedule("*/15 * * * *", async () => {
	console.log("Mengambil data setiap 15 menit...");
	await collectDataFromFirebase();
}, {
	scheduled: true,
	//timezone: "Asia/Jakarta",
});

cron.schedule("0 17 * * *", async () => {
	console.log("Menyimpan laporan harian dan menghapus riwayat lama...");
	try {
		await simpanHistory();
		await hapusHistory();
	} catch (error) {
		console.error("Terjadi kesalahan dalam proses cron job:", error.message);
	}
}, {
	scheduled: true,
	//timezone: "Asia/Jakarta",
});

module.exports = {
	ambilHistoryByPond,
	ambilHistoryById,
	simpanHistory,
	hapusHistory
};