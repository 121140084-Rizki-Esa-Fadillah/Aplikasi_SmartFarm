const mongoose = require("mongoose");

class Kolam {
      constructor() {
            const kolamSchema = new mongoose.Schema({
                  idPond: {
                        type: String,
                        required: true,
                        unique: true,
                  },
                  namePond: {
                        type: String,
                        required: true,
                  },
                  statusPond: {
                        type: String,
                        enum: ["Aktif", "Non-Aktif"],
                        default: "Aktif",
                  },
                  createdAt: {
                        type: Date,
                        default: Date.now,
                  },
            });

            this.Kolam = mongoose.model("Kolam", kolamSchema);
      }

      async ambilDataKolam() {
            return await this.Kolam.find();
      }

      async tambahKolam(data) {
            const kolam = new this.Kolam(data);
            return await kolam.save();
      }

      async editKolam(id, data) {
            return await this.Kolam.findByIdAndUpdate(id, data, {
                  new: true
            });
      }

      async hapusKolam(id) {
            return await this.Kolam.findByIdAndDelete(id);
      }

      get model() {
            return this.Kolam;
      }
}

module.exports = new Kolam();