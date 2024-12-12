var express = require("express");
const { database } = require("../database");
const roomsService = require("../services/rooms.service");
const { validateDiscount } = require("../middlewares/validateDiscount.middleware.");
const { getDateArray } = require("../utils/date");
const { validateRoom } = require("../middlewares/validateRoom.middleware");
const consumer_goodsService = require("../services/consumer_goods.service");
const router = express.Router();

// Get available rooms given startDate, endDate, number of persons
/*
    Lấy tất cả các id phòng và trừ đi các phòng có bản ghi phòng occupied từ startDate tới endDate
*/

// Xóa đồ tiêu dùng khỏi phòng
router.delete("/:roomId/goods/:goodId", async (req, res) => {
    try {
        const result = await consumer_goodsService.deleteGoodOutOfRoom({
            roomId: req.params.roomId,
            goodId: req.params.goodId,
        });
        res.send({ status: "success", message: "Xóa đồ tiêu dùng khỏi phòng thành công" });
    } catch (error) {
        console.log(error);
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

// Tạo bản báo cáo phòng
router.post("/:roomId/:createdTime/report", async (req, res) => {
    try {
        await roomsService.generateReportForRoomRecord(req.params.roomId, req.params.createdTime, req.body);
        res.send({ status: "success", message: "Tạo báo cáo thành công!" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

// Xem bản báo cáo phòng
router.get("/:roomId/:createdTime/report", async (req, res) => {
    try {
        const result = await roomsService.findReportOfRoomRecord(req.params.roomId, req.params.createdTime);
        res.send({ status: "success", data: result });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.post("/:roomId/discount", validateDiscount, async (req, res) => {
    try {
        await roomsService.applyDiscountToRoom(req.params.roomId, req.body);
        res.send({ status: "success", message: "Áp dụng khuyến mãi thành công!" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.get("/:roomId/goods", async (req, res) => {
    try {
        const result = await consumer_goodsService.findGoodsInRoom(req.params.roomId);
        res.send({ status: "success", data: result });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.post("/price/all", async (req, res) => {
    try {
        const result = await roomsService.generatePriceForAllRoomsInAMonth(req.body);
        res.send({ status: "success", message: "Tạo bảng giá cho tất cả các phòng thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.delete("/price/all", async (req, res) => {
    try {
        const result = await roomsService.deletePriceOfAllRoomsInAMonth(req.query);
        res.send({
            status: "success",
            message: `Xóa bảng giá cho tất cả các phòng trong tháng ${req.query.month}/${req.query.year} thành công`,
        });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.get("/available", async (req, res) => {
    try {
        const result = await roomsService.getAvailableRoomsForPeriod(req.query);
        res.send({ status: "success", ...result });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// Get all rooms
router.get("/all", async (req, res) => {
    try {
        const result = await roomsService.getAllRooms(req.query);
        console.log(result);
        res.send({ status: "success", data: result.data, limit: result.limit, page: result.page, total: result.total });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// router.get("/test", async (req, res) => {
//     let { startDate, endDate } = req.query;
//     const result = await roomsService.getPriceOfRoom("9eae74ec-380e-493c-a489-90084a56756e", startDate, endDate);
//     res.send(result);
// });

// Thêm đồ dùng vào phòng
router.post("/:roomId/goods", async (req, res) => {
    let roomId = req.params.roomId;
    try {
        const result = await roomsService.addConsumerGoodToRoom(roomId, req.body);
        res.send({ status: "success", message: result.message });
    } catch (error) {
        console.log(error);

        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.get("/:roomId/records", async (req, res) => {
    try {
        const result = await roomsService.getAllRoomRecords(req.params.roomId);
        res.send({ status: "success", data: result });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

// Thêm tiện nghi phòng
router.post("/:roomId/amenities", async (req, res) => {
    let roomId = req.params.roomId;
    let { amenityId } = req.body;
    if (amenityId) {
        try {
            const [result] = await database.query(`CALL ThemTienNghiPhong_Phong('${roomId}', '${amenityId}')`);
            res.send({ status: "success", message: "Thêm tiện nghi thành công" });
        } catch (error) {
            res.status(500).send({ status: "failed", error: error.message });
        }
    } else {
        res.status(400).send({ status: "failed", error: "amenityId is missing" });
    }
});

// Update room price
router.get("/:roomId/price", validateRoom, async (req, res) => {
    let roomId = req.params.roomId;
    try {
        const result = await roomsService.getPriceOfRoomInMonths({ roomId, ...req.query });
        res.status(200).send({ status: "success", data: result });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// Update room price
router.patch("/:roomId/price", validateRoom, async (req, res) => {
    let roomId = req.params.roomId;
    try {
        const result = await roomsService.alterRoomPrice(roomId, req.body);
        res.status(200).send({ status: "success", data: result });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// Xóa tiện nghi phòng (bảng TienNghiPhong_Phong)
router.delete("/:roomId/amenities", async (req, res) => {
    let roomId = req.params.roomId;
    let { amenityId } = req.query;
    if (amenityId) {
        try {
            const [result] = await database.query(`CALL XoaTienNghiPhong_Phong('${maphong}', '${amenityId}')`);
            res.send({ status: "success", message: "Xóa tiện nghi thành công" });
        } catch (error) {
            res.status(500).send({ status: "failed", error: error.message });
        }
    } else {
        res.status(400).send({ status: "failed", error: "amenityId is missing" });
    }
});

// Get room information
router.get("/:roomId", async (req, res) => {
    let roomId = req.params.roomId;
    try {
        const [room] = await database.query(`SELECT P.* FROM Phong P WHERE ${roomId} = P.MaPhong`);
        if (room.length > 0) {
            // check if the room exists
            // lấy tiện nghi phòng
            const [amenities] = await database.query(`
                SELECT * TienNghiPhong_Phong TN_P 
                JOIN TienNghiPhong TN ON TN_P.MaTienNghi = TienNghiPhong.ID
                WHERE TN_P.MaPhong = ${room[0].MaPhong}`);
            res.send({ status: "success", data: { room, amenities } });
        }
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// Update room infomation
router.patch("/:roomId", async (req, res) => {
    let roomId = req.params.roomId;
    try {
        const result = await roomsService.updateRoomInfo(roomId, req.body);
        res.send({ status: "success", message: "Cập nhật thông tin phòng thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

// create a room
router.post("/", async (req, res) => {
    try {
        const result = await roomsService.createRoom(req.body);
        if (result) {
            res.status(201).send({ status: "success", message: "Tạo phòng thành công" });
        } else {
            res.status(500).send({ status: "success", message: "Tạo phòng thất bại" });
        }
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

// router.delete("/:maphong", async (req, res) => {
//     let maphong = req.params.maphong;
//     try {
//         const [result] = await database.query(`CALL XoaPhong('${maphong}')`);
//         res.send({ status: "success", message: "Xóa phòng thành công" });
//     } catch (error) {
//         res.status(500).send({ status: "failed", error: error.message });
//     }
// });

module.exports = router;
