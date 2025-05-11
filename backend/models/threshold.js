class Threshold {
	constructor(data) {
		this.phHigh = data.ph.high;
		this.phLow = data.ph.low;
		this.salinityHigh = data.salinity.high;
		this.salinityLow = data.salinity.low;
		this.temperatureHigh = data.temperature.high;
		this.temperatureLow = data.temperature.low;
		this.turbidityHigh = data.turbidity.high;
		this.turbidityLow = data.turbidity.low;
	}

	// Method to fetch threshold data
	static async ambilDataThreshold(pondId, getDeviceConfig) {
		const data = await getDeviceConfig(pondId, "thresholds");
		return new Threshold(data);
	}

	// Method to edit thresholds
	static async editDataThreshold(pondId, thresholdData, updateDeviceConfig) {
		return await updateDeviceConfig(pondId, "thresholds", thresholdData);
	}
}

module.exports = Threshold;