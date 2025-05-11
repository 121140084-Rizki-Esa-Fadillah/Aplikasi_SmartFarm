const {
	getDeviceConfig,
	updateDeviceConfig
} = require("./firebaseHelper");
const Threshold = require("../models/threshold");

const ambilDataThreshold = async (pondId) => {
	return await Threshold.ambilDataThreshold(pondId, getDeviceConfig);
};

const editDataThreshold = async (pondId, thresholdData) => {
	return await Threshold.editDataThreshold(pondId, thresholdData, updateDeviceConfig);
};

module.exports = {
	ambilDataThreshold,
	editDataThreshold
};