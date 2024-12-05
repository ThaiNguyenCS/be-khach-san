const { database } = require("../database");

// Middleware to validate `roomId`
module.exports.validateRoom = async(req, res, next) => {
    const roomId = req.params.roomId;
    try {
        const [room] = await database.query(`SELECT * FROM Phong WHERE MaPhong = ?`, [roomId]);
        if (room.length === 0) {
            return res.status(404).send({ status: "failed", error: "Room not found" });
        }
        req.room = room[0]; // Attach room data to the request
        next();
    } catch (error) {
        res.status(500).send({ status: "failed", error: error.message });
    }
}