const createHttpError = require("http-errors");
const { database } = require("../database");
const customerService = require("./customer.service");
const roomsService = require("./rooms.service");
const room_serviceService = require("./room_service.service");
const { checkMissingField } = require("../utils/errorHandler");

class BookingService {
    async getAllOrders(query) {
        let { limit = 20, page = 1, cusPhoneNumber } = query;
        try {
            limit = parseInt(limit);
            page = parseInt(page);
            let condition = "";
            let customer = null;
            if (cusPhoneNumber) {
                customer = await customerService.findCustomerByPhoneNumber(cusPhoneNumber);
                if (!customer) {
                    throw createHttpError(404, `Không tồn tại khách hàng với số điện thoại ${cusPhoneNumber}`);
                }
                condition = ` WHERE IDKhachHang = '${customer.ID}'`;
                
            }
            const ORDER_QUERY = `SELECT * FROM DonDatPhong ${condition} LIMIT ${limit} OFFSET ${(page - 1) * limit}`;
            const COUNT_QUERY = `SELECT COUNT(*) as total FROM DonDatPhong ${condition}`;
            const [orders] = await database.query(ORDER_QUERY);
            const [count] = await database.query(COUNT_QUERY);
            if (orders.length > 0) {
                const promises = [];
                for (let i = 0; i < orders.length; i++) {
                    promises.push(this.getOrderById(orders[i].MaDon));
                }
                const result = await Promise.all(promises);
                return { data: result, limit, page, total: count[0].total };
            }
            return { data: [], limit, page, total: count[0].total };
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
                if (records.length === 0) {
                    throw createHttpError(404, `Không tìm thấy phòng đã đặt trong đơn đặt phòng ${orderId}`);
                }
                return { order: orders[0], rooms: records };
            }
            throw createHttpError(404, `Không tìm thấy đơn đặt phòng ${orderId}`);
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

  

    async getOrderByIdForCheckout(orderId) {
        try {
            // get info about order and rooms
            const { order, rooms } = await this.getOrderById(orderId);
            // get info about room records's report (đảm bảo tất cả các phòng đều đã có bản báo cáo)
            // get info about room records's service usage

            const reportPromises = [];
            const servicePromises = [];
            for (let i = 0; i < rooms.length; i++) {
                reportPromises.push(
                    roomsService.findReportOfRoomRecord(rooms[i].MaPhong, rooms[i].ThoiGianTaoBanGhiPhong)
                );
                servicePromises.push(
                    room_serviceService.getServiceOrderOfRoomRecord({
                        roomId: rooms[i].MaPhong,
                        createdAt: rooms[i].ThoiGianTaoBanGhiPhong,
                    })
                );
            }
            const [reports] = await Promise.all(reportPromises);
            console.log(reports);
            const services = await Promise.all(servicePromises);
            console.log(services);
            return { order, reports, rooms, services };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new BookingService();
