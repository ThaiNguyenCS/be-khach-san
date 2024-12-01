var express = require("express");
const { database } = require("../database");
const { generateUUIDV4 } = require("../utils/idManager");
const roomsService = require("../services/rooms.service");
const router = express.Router();

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
    let { action } = req.body;
    let orderId = req.params.orderId;
    const order = await roomsService.getOrder(orderId);
    if (order) {
        if (order.TrangThai === "cancelled") {
            res.status(403).send({ status: "failed", message: "Order is cancelled, its status cannot be changed" });
        } else {
            let UPDATE_ORDER_QUERY = `UPDATE DonDatPhong SET TrangThaiDon = ${
                action === "accept" ? "confirmed" : action === "refuse" ? "cancelled" : "not confirmed"
            } WHERE MaDon = '${orderId}'`;
            await database.query(UPDATE_ORDER_QUERY);
            res.send({ status: "success", message: "Update order successfully" });
        }
    } else {
        res.status(404).send({ status: "failed", message: "Order does not exist" });
    }
});

module.exports = router;
