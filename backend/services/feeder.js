const {
      getDeviceConfig,
      updateDeviceConfig
} = require("./firebaseHelper");
const Feeder = require("../models/feeder");

const ambilDataFeeder = async (pondId) => {
      return await Feeder.ambilDataFeeder(pondId, getDeviceConfig);
};

const editDataFeeder = async (pondId, feedingData) => {
      return await Feeder.editDataFeeder(pondId, feedingData, updateDeviceConfig);
};

module.exports = {
      ambilDataFeeder,
      editDataFeeder
};