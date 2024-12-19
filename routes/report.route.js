var express = require("express");
const reportService = require("../services/report.service");
const router = express.Router();

router.get("/orders/stat", async (req, res) => {
    try {
        const result = await reportService.getOrderStats(req.query);
        res.send({ status: "success", ...result });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.get("/all", async (req, res) => {
    try {
        const result = await reportService.getIntakeFromOrderedRooms(req.query);
        const result2 = await reportService.getIntakeFromServices(req.query);
        const result3 = await reportService.getMaintenanceCost(req.query);
        const salary = await reportService.getEmployeeSalaries(req.query);
        res.send({ status: "success", ...result, ...result2, ...result3, ...salary });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
