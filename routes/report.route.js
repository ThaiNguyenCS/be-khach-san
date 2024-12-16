var express = require("express");
const reportService = require("../services/report.service");
const router = express.Router();

router.get("/all", async (req, res) => {
    try {
        const result = await reportService.getIntakeFromOrderedRooms(req.query);
        const result2 = await reportService.getIntakeFromServices(req.query);
        const result3 = await reportService.getMaintenanceCost(req.query);
        res.send({ status: "success", ...result, ...result2, ...result3 });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
