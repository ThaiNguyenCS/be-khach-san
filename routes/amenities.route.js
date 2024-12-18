var express = require("express");
const { database } = require("../database");
const { generateUUIDV4 } = require("../utils/idManager");
const amenitiesService = require("../services/amenities.service");
const createHttpError = require("http-errors");
const router = express.Router();

//! Thống kê số lượng tiện nghi theo từng phòng (Theo chi nhánh)
router.get("/rooms/stats", async (req, res) => {
    try {
        const { branchId } = req.query;
        console.log(branchId);
        const statistics = await amenitiesService.getAmenitiesStatisticsbyBranch(branchId);
        res.send({
            status: "success",
            message: "Thống kê số lượng phòng theo từng tiện nghi",
            statistics,
        });
    } catch (error) {
        console.error("Error:", error);
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.post("/rooms", async (req, res) => {
    let { ten, moTa } = req.body;
    try {
        // CALL (IN ID VARCHAR(50), IN Ten VARCHAR(255), IN MoTa TEXT)
        const QUERY = `CALL ThemTienNghiPhong ('${generateUUIDV4()}', '${ten}', '${moTa}')`;

        const result = await database.query(QUERY);
        res.status(201).send({ status: "success", message: "Thêm tiện nghi thành công" });
    } catch (error) {
        console.log(error.message);
        res.status(500).send({ status: "failed", error: error.message });
    }
});

router.patch("/branch/:id", async (req, res) => {
    try {
        const result = await amenitiesService.updateAmenityForBranch(req.params.id, req.body);

        res.status(200).send({
            status: "success",
            message: "Sửa tiện nghi khách sạn thành công",
        });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.delete("/branch/:id", async (req, res) => {
    try {
        const result = await amenitiesService.deleteAmenityFromBranch(req.params.id);

        res.status(200).send({
            status: "success",
            message: "Xóa tiện nghi chi nhánh thành công",
        });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.post("/branch", async (req, res) => {
    try {
        const result = await amenitiesService.addAmenityForBranch(req.body);
        res.status(201).send({ status: "success", message: "Thêm tiện nghi thành công" });
    } catch (error) {
        console.log(error.message);
        res.status(500).send({ status: "failed", error: error.message });
    }
});

router.get("/branch", async (req, res) => {
    try {
        const result = await amenitiesService.getAllAmenitiesOfBranch(req.query);

        res.status(200).send({
            status: "success",
            data: result.data,
            limit: result.limit,
            page: result.page,
            total: result.total,
        });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

//! Chỉnh sửa Tiện nghi phòng
router.patch("/rooms/update/:id", async (req, res) => {
    const { id } = req.params;
    const { ten, moTa } = req.body;

    try {
        const [result] = await database.query(`UPDATE TienNghiPhong SET Ten = ?, MoTa = ? WHERE ID = ?`, [
            ten,
            moTa,
            id,
        ]);
        if (result.affectedRows === 0) {
            return res.status(404).send({ status: "failed", error: "Tiện nghi không tồn tại" });
        }
        res.send({ status: "success", message: "Cập nhật tiện nghi thành công" });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});
//! Delete
router.delete("/rooms/delete/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const [result] = await database.query(`DELETE FROM TienNghiPhong WHERE ID = ?`, [id]);
        if (result.affectedRows === 0) {
            return res.status(404).send({ status: "failed", error: "Tiện nghi không tồn tại" });
        }
        res.send({ status: "success", message: "Xóa tiện nghi thành công" });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});
//! Get All TienNghi có ở khách sạn
router.get("/rooms/all", async (req, res) => {
    try {
        const result = await amenitiesService.getAllRoomAmenities(req.query);
        res.send({ status: "success", ...result });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

//! Thêm tiện nghi vào nhiều phòng
router.post("/add/multiple", async (req, res) => {
    let { amenityId, roomIds } = req.body;
    if (!amenityId || !roomIds) {
        return res.status(400).send({ status: "failed", message: "Thiếu thông tin tiện nghi hoặc phòng" });
    }

    try {
        roomIds = JSON.parse(roomIds);
        console.log(roomIds);
        
        if (!Array.isArray(roomIds) || roomIds.length === 0) {
            throw createHttpError(400, "Thiếu thông tin phòng");
        }
        const result = await amenitiesService.addAmenityToRooms(amenityId, roomIds);

        res.send({
            status: "success",
            message: "Tiện nghi đã được thêm vào các phòng",
            data: result,
        });
    } catch (error) {
        res.status(error.status || 500).send({
            status: "failed",
            error: error.message,
        });
    }
});

//! Thêm tiện nghi vào phòng
router.post("/add/:roomId", async (req, res) => {
    const { roomId } = req.params;
    const { amenityId } = req.body;

    if (!amenityId) {
        return res.status(400).send({ status: "failed", error: "amenityId không tìm thấy" });
    }

    try {
        await database.query(`INSERT INTO TienNghiPhong_Phong (MaPhong, MaTienNghi) VALUES (?, ?)`, [
            roomId,
            amenityId,
        ]);
        res.status(201).send({ status: "success", message: "Thêm tiện nghi vào phòng thành công" });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});



//! Xóa tiện nghi khỏi phòng
router.delete("/delete/:roomId/:amenityId", async (req, res) => {
    const { roomId, amenityId } = req.params;

    try {
        const [result] = await database.query(`DELETE FROM TienNghiPhong_Phong WHERE MaPhong = ? AND MaTienNghi = ?`, [
            roomId,
            amenityId,
        ]);
        if (result.affectedRows === 0) {
            return res.status(404).send({ status: "failed", error: "Không tìm thấy tiện nghi trong phòng" });
        }
        res.send({ status: "success", message: "Xóa tiện nghi khỏi phòng thành công" });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

//! Xem thông tin tiện nghi có trong phòng
router.get("/:roomId", async (req, res) => {
    const { roomId } = req.params;

    try {
        const [amenities] = await database.query(
            `
            SELECT TNP.ID, TNP.Ten, TNP.MoTa 
            FROM TienNghiPhong_Phong TNP_P
            JOIN TienNghiPhong TNP ON TNP_P.MaTienNghi = TNP.ID
            WHERE TNP_P.MaPhong = ?
        `,
            [roomId]
        );
        res.send({ status: "success", data: amenities });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

//! Lấy danh sách các phòng có một tiện nghi cụ thể.
router.get("/list-rooms/:amenityId", async (req, res) => {
    const { amenityId } = req.params;

    try {
        const [rooms] = await database.query(
            `
            SELECT P.* 
            FROM TienNghiPhong_Phong TNP_P
            JOIN Phong P ON TNP_P.MaPhong = P.MaPhong
            WHERE TNP_P.MaTienNghi = ?
        `,
            [amenityId]
        );
        res.send({ status: "success", data: rooms });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

//! Check xem tiện nghi abc có ở phòng này không
router.get("/:roomId/:amenityId", async (req, res) => {
    const { roomId, amenityId } = req.params;

    try {
        const [result] = await database.query(
            `
            SELECT * FROM TienNghiPhong_Phong 
            WHERE MaPhong = ? AND MaTienNghi = ?
        `,
            [roomId, amenityId]
        );

        if (result.length === 0) {
            return res.status(404).send({ status: "failed", error: "Tiện nghi không tồn tại trong phòng" });
        }

        res.send({
            status: "success",
            message: "Tiện nghi này có trong phòng",
            data: result[0],
        });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

module.exports = router;
