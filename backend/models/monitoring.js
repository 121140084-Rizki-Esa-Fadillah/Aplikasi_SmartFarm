class Monitoring {
	constructor(data) {
		this.ph = data.ph;
		this.salinity = data.salinity;
		this.temperature = data.temperature;
		this.turbidity = data.turbidity;
		this.rtcTime = data.rtc_time ? new Date(data.rtc_time) : null;
		this.rainStatus = data.rain_status??false;
	}

	static async ambilDataMonitoring(pondId, getMonitoringData) {
		const data = await getMonitoringData(pondId);
		return new Monitoring({
			ph: data.ph,
			salinity: data.salinity,
			temperature: data.temperature,
			turbidity: data.turbidity,
			rtc_time: data.rtc_time,
			rain_status: data.rain_status
		});
	}
}

module.exports = Monitoring;