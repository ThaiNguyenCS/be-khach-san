const createHttpError = require("http-errors");
const { database } = require("../database");
const customerService = require("./customer.service");

class BookingService {
    async getAllOrders(query) {
        let { limit = 20, page = 1, cusPhoneNumber } = query;
        try {
            limit = parseInt(limit);
            page = parseInt(page);
            const customer = await customerService.findCustomerByPhoneNumber(cusPhoneNumber);
            if (customer) {
                const ORDER_QUERY = `SELECT * FROM DonDatPhong WHERE IDKhachHang = '${customer.ID}'`;
                const [orders] = await database.query(ORDER_QUERY);
                if (orders.length > 0) {
                    const promises = [];
                    for (let i = 0; i < orders.length; i++) {
                        promises.push(this.getOrderById(orders[i].MaDon));
                    }
                    const result = await Promise.all(promises);
                    return result;
                }
                return [];
            } else {
                throw createHttpError(404, `Không tồn tại khách hàng với số điện thoại ${cusPhoneNumber}`);
            }
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getOrderById(orderId) {
        try {
            const ORDER_QUERY = `SELECT * FROM DonDatPhong WHERE MaDon = '${orderId}' LIMIT 1`;
            const [orders] = await database.query(ORDER_QUERY);
            if (orders.length > 0) {
                const ROOM_RECORD_QUERY = `SELECT * FROM BanGhiPhong WHERE MaDatPhong = '${orderId}'`;
                const [records] = await database.query(ROOM_RECORD_QUERY);
                return { order: orders[0], rooms: records };
            }
            throw createHttpError(404, `Không tìm thấy đơn đặt phòng ${orderId}`);
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new BookingService();
