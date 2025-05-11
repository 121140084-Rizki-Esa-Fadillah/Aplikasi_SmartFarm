class Feeder {
      constructor(amount, schedule, status) {
            this.amountFeeder = amount;
            this.schedule_1 = schedule?.[0]??null;
            this.schedule_2 = schedule?.[1]??null;
            this.schedule_3 = schedule?.[2]??null;
            this.schedule_4 = schedule?.[3]??null;
            this.feedStatus = status??false;
      }

      // Static method to fetch feeding data
      static async ambilDataFeeder(pondId, getDeviceConfig) {
            const data = await getDeviceConfig(pondId, "feeding_schedule");
            return new Feeder(data.amount, data.schedule, data.status);
      }

      // Static method to edit feeding data
      static async editDataFeeder(pondId, feedingData, updateDeviceConfig) {
            return await updateDeviceConfig(pondId, "feeding_schedule", feedingData);
      }
}

module.exports = Feeder;