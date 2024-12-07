var express = require("express");
const roomsService = require("../services/rooms.service");
const room_serviceService = require("../services/room_service.service");
const discountService = require("../services/discount.service");
const router = express.Router();

// Xem thông tin dịch vụ phòng (menu)
router.get("/all", async (req, res) => {
    try {
        const [result] = await discountService.getAllActiveDiscount(req.query);
        return { status: "success", data: result };
    } catch (error) {
        res.status(error.message).send({ status: "failed", message: error.message });
    }
});

// Xóa dịch vụ phòng (menu)
router.delete("/:id", async (req, res) => {
    try {
    } catch (error) {
        res.status(error.message).send({ status: "failed", message: error.message });
    }
});

// Thêm dịch vụ phòng (menu)
router.post("/", async (req, res) => {
    try {
    } catch (error) {
        res.status(error.message).send({ status: "failed", message: error.message });
    }
});

// Sửa thông tin dịch vụ phòng (menu)
router.delete("/:id", async (req, res) => {
    try {
    } catch (error) {
        res.status(error.message).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
