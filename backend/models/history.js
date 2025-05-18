const mongoose = require("mongoose");

class HistoryModel {
	constructor() {
		const HistorySchema = new mongoose.Schema({
			idPond: {
				type: String,
				required: true,
			},
			date: {
				type: String,
				required: true,
			},
			data: [
				{
					time: String,
					temperature: Number,
					ph: Number,
					salinity: Number,
					turbidity: Number,
					rain_status: Boolean,
				},
			],
			created_at: {
				type: Date,
				default: Date.now,
			},
		});

		this.History = mongoose.model("History", HistorySchema);
	}

	async ambilHistoryByPond(idPond) {
		return await this.History.find({ idPond }).sort({ date: -1 });
	}

	async ambilHistoryById(id) {
		return await this.History.findById(id);
	}

	async simpanHistory(idPond, date, data) {
		const newHistory = new this.History({ idPond, date, data });
		return await newHistory.save();
	}

	async hapusHistory(date) {
		return await this.History.deleteMany({ created_at: { $lt: date } });
	}

	get model() {
		return this.History;
	}
}

module.exports = new HistoryModel();
