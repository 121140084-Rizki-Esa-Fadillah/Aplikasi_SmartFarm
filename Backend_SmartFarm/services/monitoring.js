const Monitoring = require("../models/monitoring");
const {
      getMonitoringData
} = require("./firebaseHelper");

const ambilDataMonitoring = async (pondId) => {
      return await Monitoring.ambilDataMonitoring(pondId, getMonitoringData);
};

module.exports = {
      ambilDataMonitoring
};