var express = require("express");
const { database } = require("../database");
const router = express.Router();

// Get available rooms given startDate, endDate, number of persons
/*
    Lấy tất cả các id phòng và trừ đi các phòng có bản ghi phòng occupied từ startDate tới endDate
 */
router.get("/available", async (req, res) => {
    let { startDate, endDate, quantity, limit = 20, page = 1 } = req.query;
    limit = parseInt(limit)
    page = parseInt(page)
    try {
        let QUERY = `SELECT P.* FROM Phong P WHERE NOT EXISTS (
            SELECT * FROM BanGhiPhong BG 
            JOIN DonDatPhong DDP ON BG.MaDatPhong = DDP.MaDon
            WHERE BG.MaPhong = P.MaPhong AND
            DATE('${startDate}') <= DDP.NgayTraPhong AND
            DATE('${endDate}') >= DDP.NgayNhanPhong)
            LIMIT ${limit}
            OFFSET ${limit * (page-1)}`;
        console.log(QUERY);

        const [result] = await database.query(QUERY);
        res.send({ status: "success", data: result });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

router.get("/all", async (req, res) => {
    let { limit, page } = req.query;
    try {
        const [rooms] = await database.query(`SELECT P.* FROM Phong P`);
        res.send({ status: "success", data: rooms });
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
});

router.get("/:maphong", async (req, res) => {
    let maphong = req.params.maphong;
    try {
        const [room] = await database.query(`SELECT P.* FROM Phong P WHERE ${maphong} = P.MaPhong`);
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
// Get all rooms

module.exports = router;
