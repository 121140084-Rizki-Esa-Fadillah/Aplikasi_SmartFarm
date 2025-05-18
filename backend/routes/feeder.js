const express = require("express");
const router = express.Router();
const {
      ambilDataFeeder,
      editDataFeeder
} = require("../services/feeder");

router.get("/:pondId", async (req, res) => {
      try {
            const data = await ambilDataFeeder(req.params.pondId);
            res.json(data);
      } catch (error) {
            res.status(500).json({
                  message: error.message,
            });
      }
});

router.put("/:pondId", async (req, res) => {
      try {
            const result = await editDataFeeder(req.params.pondId, req.body);
            res.json(result);
      } catch (error) {
            res.status(500).json({
                  message: error.message,
            });
      }
});

module.exports = router;