const mongoose = require("mongoose");

class Notifikasi {
      constructor() {
            const NotifikasiSchema = new mongoose.Schema({
                  idPond: {
                        type: String,
                        required: true,
                        index: true
                  },
                  type: {
                        type: String,
                        required: true,
                        enum: [
                              "feed_alert",
                              "water_quality_alert",
                              "threshold_update",
                              "feed_schedule_update",
                              "aerator_control_update"
                        ]
                  },
                  title: {
                        type: String,
                        required: true
                  },
                  message: {
                        type: String,
                        required: true
                  },
                  time: {
                        type: Date,
                        required: true
                  },
                  status: {
                        type: String,
                        enum: ["unread", "read"],
                        default: "unread"
                  },
                  metadata: {
                        type: mongoose.Schema.Types.Mixed,
                        default: {}
                  },
                  created_at: {
                        type: Date,
                        default: Date.now,
                        immutable: true
                  }
            });

            NotifikasiSchema.index({
                  idPond: 1,
                  type: 1,
                  created_at: -1
            });

            this.Notifikasi = mongoose.model("Notification", NotifikasiSchema);
      }

      // Method to create a new notification
      async buatNotifikasi(data) {
            const notif = new this.Notifikasi(data);
            return await notif.save();
      }

      // Method to get notification by ID
      async ambilNotifikasiById(id) {
            return await this.Notifikasi.findById(id);
      }

      // Method to get notifications by Pond ID
      async ambilNotifikasiByPond(idPond) {
            return await this.Notifikasi.find({
                  idPond
            }).sort({
                  created_at: -1
            });
      }

      // Method to delete notifications older than 7 days
      async hapusNotifikasi() {
            const batas = new Date();
            batas.setDate(batas.getDate() - 7);
            return await this.Notifikasi.deleteMany({
                  created_at: {
                        $lt: batas
                  }
            });
      }

      // Method to mark a notification as read
      async tandaiNotifikasi(id) {
            return await this.Notifikasi.findByIdAndUpdate(id, {
                  status: "read"
            }, {
                  new: true
            });
      }

      // Getter for the notification model
      get model() {
            return this.Notifikasi;
      }
}

module.exports = new Notifikasi();