const {
      getDeviceConfig,
      updateDeviceConfig
} = require("./firebaseHelper");
const Aerator = require("../models/aerator");

const ambilDataAerator = async (pondId) => {
      return await Aerator.ambilDataAerator(pondId, getDeviceConfig);
};

const editDataAerator = async (pondId, aeratorData) => {
      return await Aerator.editDataAerator(pondId, aeratorData, updateDeviceConfig);
};

module.exports = {
      ambilDataAerator,
      editDataAerator
};