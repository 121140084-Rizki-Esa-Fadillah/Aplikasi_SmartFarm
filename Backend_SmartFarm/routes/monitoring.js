const express = require("express");
const router = express.Router();
const {
      ambilDataMonitoring
} = require("../services/monitoring");

router.get("/:pondId", async (req, res) => {
      try {
            const data = await ambilDataMonitoring(req.params.pondId);
            res.json(data);
      } catch (error) {
            res.status(500).json({
                  message: error.message
            });
      }
});

module.exports = router;