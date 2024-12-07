const express = require("express");
const { database } = require("../database");
const router = express.Router();
const {validateRoom} = require("../middlewares/validateRoom.middleware")

// Lấy all facilities in Room
router.get("/:roomId/facilities", validateRoom, async (req, res) => {
    const roomId = req.params.roomId;
    try {
        const [facilities] = await database.query(`
            SELECT * FROM CoSoVatChatPhong WHERE MaPhong = ?
        `, [roomId]);
        res.send({ status: "success", data: facilities });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// Add a facility to a room
router.post("/:roomId/facilities/create", validateRoom, async (req, res) => {
    const roomId = req.params.roomId;
    const { id, tenTrangBi, giaMua, maSanPham, tinhTrang, imageURL  } = req.body;

    // Validate input
    if (!id || !tenTrangBi || !giaMua || !tinhTrang || !imageURL ) {
        return res.status(400).send({ status: "failed", error: "Missing required fields" });
    }

    if (!['broken', 'maintenance', 'good'].includes(tinhTrang)) {
        return res.status(400).send({ status: "failed", error: "Invalid TinhTrang value" });
    }

    try {
        await database.query(`
            INSERT INTO CoSoVatChatPhong (ID, TenTrangBi, GiaMua, MaSanPham, TinhTrang, MaPhong, imageURL )
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `, [id, tenTrangBi, giaMua, maSanPham, tinhTrang, roomId, imageURL ]);
        res.status(201).send({ status: "success", message: "Facility added successfully" });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// Update a facility in a room
router.patch("/:roomId/facilities/update/:facilityId", validateRoom, async (req, res) => {
    const roomId = req.params.roomId;
    const facilityId = req.params.facilityId;
    const { tenTrangBi, giaMua, maSanPham, tinhTrang, imageURL  } = req.body;

    if (tinhTrang && !['broken', 'maintenance', 'good'].includes(tinhTrang)) {
        return res.status(400).send({ status: "failed", error: "Invalid TinhTrang value" });
    }

    try {
        await database.query(`
            UPDATE CoSoVatChatPhong
            SET TenTrangBi = COALESCE(?, TenTrangBi),
                GiaMua = COALESCE(?, GiaMua),
                MaSanPham = COALESCE(?, MaSanPham),
                TinhTrang = COALESCE(?, TinhTrang),
                imageURL  = COALESCE(?, imageURL )
            WHERE ID = ? AND MaPhong = ?
        `, [tenTrangBi, giaMua, maSanPham, tinhTrang, imageURL , facilityId, roomId]);
        res.send({ status: "success", message: "Facility updated successfully" });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// Delete a facility from a room
router.delete("/:roomId/facilities/:facilityId", validateRoom, async (req, res) => {
    const roomId = req.params.roomId;
    const facilityId = req.params.facilityId;

    try {
        await database.query(`
            DELETE FROM CoSoVatChatPhong WHERE ID = ? AND MaPhong = ?
        `, [facilityId, roomId]);
        res.send({ status: "success", message: "Facility removed successfully" });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

// Xem thông tin facilities trong phòng
router.get("/:roomId/facilities/:facilityId", validateRoom, async (req, res) => {
    const { roomId, facilityId } = req.params;
    try {
        const [facility] = await database.query(`
            SELECT * FROM CoSoVatChatPhong WHERE ID = ? AND MaPhong = ?
        `, [facilityId, roomId]);
        if (facility.length === 0) {
            return res.status(404).send({ status: "failed", error: "Facility not found" });
        }
        res.send({ status: "success", data: facility[0] });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});


module.exports = router;
