const createHttpError = require("http-errors");
const { generateUUIDV4 } = require("../utils/idManager");
const { database } = require("../database");
const { formatDate } = require("date-fns");
const { ca } = require("date-fns/locale");
class RoomService {
    // use when receptionist accept the order

    async getPriceOfRoom(roomId, startDate, endDate) {
        let fStartDate = formatDate(startDate, "yyyy-MM-dd");
        let fEndDate = formatDate(endDate, "yyyy-MM-dd");
        const PRICE_QUERY = `SELECT SUM(GiaCongBo) AS GIATIEN FROM BangGia WHERE MaPhong = '${roomId}' AND 
        ThoiGianBatDauApDung >= DATE('${fStartDate}') AND ThoiGianBatDauApDung <= DATE('${fEndDate}')`;

        const [result] = await database.query(PRICE_QUERY);
        return result[0];
    }

    async createRoomRecord(connection, roomIds, orderId) {
        if (connection) {
            const ORDER_QUERY = `SELECT * FROM DonDatPhong DDP WHERE DDP.MaDon = '${orderId}'`;
            const [order] = await connection.query(ORDER_QUERY);

            console.log("order", order[0]);

            let ROOM_RECORD_ADD_QUERY = `INSERT INTO BanGhiPhong (MaPhong , ThoiGianTaoBanGhiPhong , MaDatPhong , GiaTien) VALUES`;
            for (let i = 0; i < roomIds.length; i++) {
                const { GIATIEN } = await this.getPriceOfRoom(
                    roomIds[i],
                    order[0].NgayNhanPhong,
                    order[0].NgayTraPhong
                );

                ROOM_RECORD_ADD_QUERY += `('${roomIds[i]}', NOW(), '${orderId}', ${GIATIEN}),`;
            }
            ROOM_RECORD_ADD_QUERY = ROOM_RECORD_ADD_QUERY.substring(0, ROOM_RECORD_ADD_QUERY.length - 1); // discard the last comma
            console.log(ROOM_RECORD_ADD_QUERY);

            await connection.query(ROOM_RECORD_ADD_QUERY);
        } else {
            console.log("no connection");
            throw createHttpError(500, "Something's wrong");
        }
    }

    async updateRoomInfo(roomId, data) {
        let { status, description, housekeeperId, discountId, roomInChargePersonID, capacity, linkedRoomId } = data;
        try {
            const updates = [];
            if (status) {
                updates.push(`TrangThai = '${status}'`);
            }
            if (description) {
                updates.push(`MoTa = '${description}'`);
            }
            if (housekeeperId) {
                updates.push(`IDNhanVienDonPhong = '${housekeeperId}'`);
            }
            if (roomInChargePersonID) {
                updates.push(`IDNhanVienPhong = '${roomInChargePersonID}'`);
            }
            if (discountId) {
                updates.push(`IDGiamGia = '${discountId}'`);
            }
            if (capacity) {
                capacity = parseInt(capacity);
                updates.push(`SucChua = ${capacity}`);
            }
            if (linkedRoomId) {
                updates.push(`MaPhongLienKet = '${linkedRoomId}'`);
            }
            const UPDATE_QUERY = `UPDATE Phong SET ${updates.join(", ")} WHERE MaPhong = '${roomId}'`;
            const [result] = await database.query(UPDATE_QUERY);
            return result;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    // get order information for customer
    async getOrderForCustomer(orderId) {
        const ORDER_QUERY = `SELECT * FROM DonDatPhong DDP JOIN BanGhiPhong BGP ON DDP.MaDon = BGP.MaDatPhong
        WHERE DDP.MaDon = '${orderId}'`;
        const [result] = await database.query(ORDER_QUERY);
        return result;
    }

    async getOrder(orderId) {
        const ORDER_QUERY = `SELECT * FROM DonDatPhong DDP WHERE DDP.MaDon = '${orderId}'`;
        const [result] = await database.query(ORDER_QUERY);
        return result[0];
    }

    async createRoom(data) {
        let { branchId, type, description, capacity, roomNumber } = data;

        if (!branchId) {
            throw createHttpError(400, "branchId is required");
        }

        if (!type) {
            throw createHttpError(400, "type is required");
        }

        if (!roomNumber) {
            throw createHttpError(400, "roomNumber is required");
        }
        roomNumber = parseInt(roomNumber);

        if (capacity) {
            capacity = parseInt(capacity);
        }

        try {
            const newRoomId = generateUUIDV4();
            const INSERT_ROOM_QUERY = `INSERT INTO Phong (MaPhong, MaChiNhanh, LoaiPhong, MoTa, SucChua, SoPhong)
            VALUES ('${newRoomId}', '${branchId}', '${type}', '${description}', ${capacity}, ${roomNumber})`;

            await database.query(INSERT_ROOM_QUERY);
            return true;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    async alterRoomPrice(roomId, data) {
        let { minPrice, publicPrice, startDate, endDate } = data;
        if (!minPrice && !publicPrice) {
            throw createHttpError(400, "price is missing");
        }
        if (!startDate) {
            throw createHttpError(400, "startDate is missing");
        }

        try {
            if (!endDate) {
                endDate = startDate;
            }

            let fStartDate = formatDate(new Date(startDate), "yyyy-MM-dd");
            let fEndDate = formatDate(new Date(endDate), "yyyy-MM-dd");

            const updates = [];
            if (minPrice) {
                minPrice = parseFloat(minPrice);
                updates.push(`GiaThapNhat = ${minPrice}`);
            }

            if (publicPrice) {
                publicPrice = parseFloat(publicPrice);
                updates.push(`GiaCongBo = ${publicPrice}`);
            }

            const UPDATE_QUERY = `UPDATE BangGia SET ${updates.join(
                ", "
            )} WHERE MaPhong = '${roomId}' AND ThoiGianBatDauApDung >= DATE('${fStartDate}') AND ThoiGianBatDauApDung <= DATE('${fEndDate}')`;
            console.log(UPDATE_QUERY);

            const [result] = await database.query(UPDATE_QUERY);
            return result;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new RoomService();
