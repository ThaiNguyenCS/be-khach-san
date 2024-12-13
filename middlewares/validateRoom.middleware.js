const { database } = require("../database");
const consumer_goodsService = require("../services/consumer_goods.service");
const roomsService = require("../services/rooms.service");
const { checkMissingField } = require("../utils/errorHandler");

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

const verifyGoodsInRoom = async (req, res, next) => {
    let {roomId, createdAt} = req.params
    let {goods} = req.body
    try {
        checkMissingField("roomId", roomId)
        checkMissingField("createdAt", createdAt)
        checkMissingField("goods", goods)
        goods = JSON.parse(goods)
        if(!Array.isArray(goods))
        {
            return res.status(400).send({status: "failed", message: `Format của data không hợp lệ`})
        }
        if(goods.length > 0)
        {
            const inRoomGoods = await consumer_goodsService.findGoodsInRoom(roomId)
            for (let i = 0; i < goods.length; i++)
            {
                const foundGood = inRoomGoods.find(item => item.MaDoTieuDung === goods[i].goodId)
                if(!foundGood)
                {
                    return res.status(403).send({status: "failed", message: `Vật phẩm ${goodId} không tồn tại trong phòng ${roomId}`})
                }
                else
                {
                    // check if input is negative
                    if(parseInt(goods[i].quantity) < 0)
                    {
                        return res.status(403).send({status: "failed", message: `Vật phẩm ${goodId} với số lượng âm`})
                    }
                    // check if input is more than in room has
                    if(foundGood.SoLuong < parseInt(goods[i].quantity))
                    {
                        return res.status(403).send({status: "failed", message: `Số lượng vật phẩm trong phòng không đủ`})
                    }
                }
            }
        }
        next()

    } catch (error) {
        res.status(500).send({status: "failed", message: error.message})
    }
}

module.exports = { validateRoom, verifyRoomsThatAvailable, verifyGoodsInRoom };
