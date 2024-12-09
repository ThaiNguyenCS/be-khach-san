var express = require("express");
const { database } = require("../database");
const { generateUUIDV4 } = require("../utils/idManager");
const roomsService = require("../services/rooms.service");
const bookingService = require("../services/booking.service");
const room_serviceService = require("../services/room_service.service");
const router = express.Router();

// Lấy tất cả đơn đặt phòng cho khách
router.get("/all", async (req, res) => {
    try {
        const result = await bookingService.getAllOrders(req.query);
        res.send({ status: "success", data: result });
    } catch (error) {
        console.log(error.message);
        res.status(500).send({ status: "failed", error: error });
    }
});

// Sửa đơn sử dụng dịch vụ
router.patch("/room-service/:orderId", async (req, res) => {
    try {
        const result = await room_serviceService.updateServiceOrderForRoomRecord({
            ...req.body,
            orderId: req.params.orderId,
        });
        res.send({ status: "success", message: "Cập nhật đơn sử dụng dịch vụ thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error });
    }
});

// Xóa đơn sử dụng dịch vụ
router.delete("/room-service/:orderId", async (req, res) => {
    try {
        const result = await room_serviceService.deleteServiceOrderForRoomRecord({
            ...req.query,
            orderId: req.params.orderId,
        });
        res.send({ status: "success", message: "Xóa đơn sử dụng dịch vụ thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error });
    }
});

// Lấy tất cả các đơn sử dụng dịch vụ của 1 room record
router.get("/room-service", async (req, res) => {
    try {
        const result = await room_serviceService.getServiceOrderOfRoomRecord(req.query);
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error });
    }
});

// Đặt đơn sử dụng dịch vụ
router.post("/room-service", async (req, res) => {
    try {
        const result = await room_serviceService.createServiceOrderForRoomRecord(req.body);
        res.send({ status: "success", message: "Tạo đơn sử dụng dịch vụ thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error });
    }
});

// Lấy đơn đặt phòng cụ thể
router.get("/:orderId/checkout", async (req, res) => {
    try {
        const result = await bookingService.getOrderByIdForCheckout(req.params.orderId);
        res.send({ status: "success", data: result });
    } catch (error) {
        console.log(error.message);
        res.status(500).send({ status: "failed", error: error });
    }
});

// Lấy đơn đặt phòng cụ thể
router.get("/:orderId", async (req, res) => {
    try {
        const result = await bookingService.getOrderById(req.params.orderId);
        res.send({ status: "success", data: result });
    } catch (error) {
        console.log(error.message);
        res.status(500).send({ status: "failed", error: error });
    }
});

// booking rooms
router.post("/", async (req, res) => {
    let { roomIds, checkInDate, checkOutDate, cusName, cusPhoneNumber, cusCitizenId, cusSex, cusDOB, deposit } =
        req.body;
    if (deposit) deposit = parseInt(deposit);
    if (roomIds) {
        roomIds = JSON.parse(roomIds);
    } else {
        return res.status(400).send({ status: "failed", error: "roomIds is empty" });
    }
    const connection = await database.getConnection();

    try {
        // CALL (IN ID VARCHAR(50), IN Ten VARCHAR(255), IN MoTa TEXT)
        await connection.beginTransaction();
        const FIND_CUS_QUERY = `SELECT * FROM KhachHang WHERE SoDienThoai = '${cusPhoneNumber}'`;
        const [customer] = await connection.query(FIND_CUS_QUERY);
        let cusId = customer[0]?.ID;
        if (customer.length === 0) {
            cusId = generateUUIDV4();
            // Tạo khách hàng mới
            const ADD_CUS_QUERY = `INSERT INTO KhachHang (ID, Ten, CCCD, SoDienThoai, NgaySinh, GioiTinh) 
            VALUES ('${cusId}', 
            '${cusName}',
            '${cusCitizenId}',
            '${cusPhoneNumber}',
            '${cusDOB}',
            '${cusSex}')`;
            await connection.query(ADD_CUS_QUERY);
        }

        let orderId = generateUUIDV4();
        // Tạo đơn đặt phòng
        const BOOKING_QUERY = `INSERT INTO DonDatPhong (MaDon, IDKhachHang, ThoiGianDat, TrangThaiDon, NgayNhanPhong, NgayTraPhong, Nguon, SoTienDatCoc) VALUES ('${orderId}', '${cusId}', NOW(), 'not confirmed', DATE('${checkInDate}'), DATE('${checkOutDate}') , 'Website', ${deposit})`;
        await connection.query(BOOKING_QUERY);

        // Tạo bản ghi phòng
        await roomsService.createRoomRecord(connection, roomIds, orderId);

        await connection.commit();
        res.status(201).send({ status: "success", message: "Đặt đơn thành công" });
    } catch (error) {
        console.log(error.message);
        await connection.rollback();
        res.status(500).send({ status: "failed", error: error });
    }
});

// for receptionist
router.patch("/:orderId", async (req, res) => {
    let orderId = req.params.orderId;
    try {
        const result = await roomsService.updateOrderStatus(orderId, req.body);
        res.send({ status: "success", message: "Update order successfully" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
