const createHttpError = require("http-errors");
const { database } = require("../database");
const { checkMissingField } = require("../utils/errorHandler");
const { generateUUIDV4 } = require("../utils/idManager");

class ReceiptService {
    async generateReceiptForOrder(orderId) {
        try {
            checkMissingField("orderId", orderId);
            const receipt = await this.getReceiptForOrder(orderId);
            if (receipt.length > 0) throw createHttpError(403, `Hóa đơn cho đơn đặt phòng ${orderId} đã tồn tại.`);
            const newReceiptId = generateUUIDV4();
            const QUERY = `INSERT INTO HoaDon (MaHoaDon, ThoiGianXuatHoaDon, MaDon) VALUES ('${newReceiptId}', NOW(), '${orderId}')`;
            console.log(QUERY);
            
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getReceiptForOrder(orderId) {
        try {
            checkMissingField("orderId", orderId);
            const QUERY = `SELECT * FROM HoaDon WHERE MaDon = '${orderId}'`;
            const [receipt] = await database.query(QUERY);
            return receipt;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}
module.exports = new ReceiptService();
