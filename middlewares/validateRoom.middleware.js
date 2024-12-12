const { database } = require("../database");
const roomsService = require("../services/rooms.service");

// Middleware to validate `roomId`
const validateRoom = async (req, res, next) => {
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
};

const verifyRoomsThatAvailable = async (req, res, next) => {
    try {


        await roomsService._verifyRoomsForOrder({
            startDate: req.body.checkInDate,
            endDate: req.body.checkOutDate,
            roomIds: req.body.roomIds,
        });
        // console.log(result);
        next();
    } catch (error) {
        if (error.status) {
            return res.status(error.status).send({ status: "failed", message: error.message });
        }
        return res.status(500).send({ status: "failed", message: error.message });
    }
};

module.exports = { validateRoom, verifyRoomsThatAvailable };
