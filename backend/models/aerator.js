class Aerator {
      constructor(aerator_delay, status) {
            this.aeratorOnMinuteAfter = aerator_delay;
            this.statusAerator = status?.on??false;
      }

      // Static method to fetch aerator data
      static async ambilDataAerator(pondId, getDeviceConfig) {
            const data = await getDeviceConfig(pondId, "aerator");
            return new Aerator(data.aerator_delay, data.status);
      }

      // Static method to edit aerator data
      static async editDataAerator(pondId, aeratorData, updateDeviceConfig) {
            return await updateDeviceConfig(pondId, "aerator", aeratorData);
      }
}

module.exports = Aerator;