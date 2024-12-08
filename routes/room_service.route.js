var express = require("express");
const roomsService = require("../services/rooms.service");
const room_serviceService = require("../services/room_service.service");
const router = express.Router();

// Xem thông tin dịch vụ phòng (menu)
router.get("/all", async (req, res) => {
    try {
        const result = await room_serviceService.getAllRoomService(req.query);
        return res.send({ status: "success", data: result });
    } catch (error) {
        res.status(error.message).send({ status: "failed", message: error.message });
    }
});

// Xóa dịch vụ phòng (menu)
router.delete("/", async (req, res) => {
    try {
        await room_serviceService.deleteRoomService(req.query);
        return res.send({ status: "success", message: "Xóa dịch vụ phòng thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

// Thêm dịch vụ phòng (menu)
router.post("/", async (req, res) => {
    try {
        await room_serviceService.addRoomService(req.body);
        return res.send({ status: "success", message: "Thêm dịch vụ phòng thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

// Sửa thông tin dịch vụ phòng (menu)
router.patch("/", async (req, res) => {
    try {
        await room_serviceService.updateRoomService(req.body);
        return res.send({ status: "success", message: "Sửa thông tin dịch vụ phòng thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
