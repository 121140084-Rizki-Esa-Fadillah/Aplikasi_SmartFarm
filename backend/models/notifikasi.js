const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema({
      idPond: {
            type: String,
            required: true,
            index: true
      },
      type: {
            type: String,
            required: true,
            enum: ["feed_alert", "water_quality_alert", "threshold_update", "feed_schedule_update", "aerator_control_update"]
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
      },
});

// ✅ Optimasi pencarian dengan index tambahan
notificationSchema.index({
      idPond: 1,
      type: 1,
      createdAt: -1
});

module.exports = mongoose.model("Notification", notificationSchema);