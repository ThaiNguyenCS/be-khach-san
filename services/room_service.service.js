const createHttpError = require("http-errors");
const { database } = require("../database");
const { checkMissingField } = require("../utils/errorHandler");
const { handleParameterIfNull } = require("../utils/sqlParamHandler");
const { formatDate, differenceInHours } = require("date-fns");
const { generateUUIDV4 } = require("../utils/idManager");
const { formatDateTime } = require("../utils/date");
class RoomService {
    async addRoomService(data) {
        let { serviceId, type, price, description, vehicleType, washingOption, roomCapacity } = data;

        try {
            checkMissingField("type", type);
            checkMissingField("price", price);
            checkMissingField("description", description);
            type = type.toLowerCase();
            price = parseFloat(price);
            roomCapacity = parseInt(roomCapacity);

            switch (type) {
                case "laundry": {
                    checkMissingField("washingOption", washingOption);
                    await database.query(
                        `CALL CreateDichVuGiatUi ('${serviceId}', '${washingOption}', ${price}, '${description}')`
                    );
                    return true;
                }
                case "transport": {
                    checkMissingField("vehicleType", vehicleType);
                    await database.query(
                        `CALL CreateDichVuDuaDon ('${serviceId}', '${vehicleType}', ${price}, '${description}')`
                    );
                    return true;
                }
                case "food": {
                    await database.query(`CALL CreateDichVuAnUong('${serviceId}', ${price}, '${description}')`);
                    return true;
                }
                case "meeting room": {
                    checkMissingField("roomCapacity", roomCapacity);
                    await database.query(
                        `CALL CreateDichVuPhongHop('${serviceId}', ${roomCapacity}, ${price}, '${description}')`
                    );
                    return true;
                }
                default: {
                    throw createHttpError(400, "Loại dịch vụ không hợp lệ");
                }
            }
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async deleteRoomService(query) {
        let { serviceId, type } = query;
        try {
            checkMissingField("type", type);
            checkMissingField("serviceId", serviceId);
            type = type.toLowerCase();
            switch (type) {
                case "laundry": {
                    const [result] = await database.query(`CALL DeleteDichVuGiatUi ('${serviceId}')`);
                    console.log(result);
                    if (result.affectedRows === 0) {
                        throw createHttpError(404, "Không tìm thấy dịch vụ");
                    }
                    return true;
                }
                case "transport": {
                    const [result] = await database.query(`CALL DeleteDichVuDuaDon ('${serviceId}')`);
                    console.log(result);
                    if (result.affectedRows === 0) {
                        throw createHttpError(404, "Không tìm thấy dịch vụ");
                    }
                    return true;
                }
                case "food": {
                    const [result] = await database.query(`CALL DeleteDichVuAnUong ('${serviceId}')`);
                    console.log(result);
                    if (result.affectedRows === 0) {
                        throw createHttpError(404, "Không tìm thấy dịch vụ");
                    }
                    return true;
                }
                case "meeting room": {
                    const [result] = await database.query(`CALL DeleteDichVuPhongHop('${serviceId}')`);
                    console.log(result);
                    if (result.affectedRows === 0) {
                        throw createHttpError(404, "Không tìm thấy dịch vụ");
                    }
                    return true;
                }
                default: {
                    throw createHttpError(400, "Loại dịch vụ không hợp lệ");
                }
            }
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async updateRoomService(data) {
        let {
            serviceId,
            type,
            price = null,
            description = null,
            vehicleType = null,
            washingOption = null,
            roomCapacity = null,
        } = data;
        try {
            checkMissingField("type", type);
            checkMissingField("serviceId", serviceId);
            type = type.toLowerCase();
            if (price) price = parseFloat(price);
            if (roomCapacity) roomCapacity = parseInt(roomCapacity);

            switch (type) {
                case "laundry": {
                    const [result] = await database.query(
                        `CALL UpdateDichVuGiatUi ('${serviceId}', ${
                            washingOption ? `"${washingOption}"` : "NULL"
                        }, ${price}, '${description}')`
                    );
                    console.log(
                        `CALL UpdateDichVuGiatUi ('${serviceId}', ${handleParameterIfNull(
                            washingOption
                        )}, ${handleParameterIfNull(price)}, ${handleParameterIfNull(description)})`
                    );

                    if (result.affectedRows === 0) {
                        throw createHttpError(404, "Không tìm thấy dịch vụ");
                    }
                    return true;
                }
                case "transport": {
                    const [result] = await database.query(
                        `CALL UpdateDichVuDuaDon ('${serviceId}', ${handleParameterIfNull(
                            vehicleType
                        )}, ${handleParameterIfNull(price)}, ${handleParameterIfNull(description)})`
                    );
                    if (result.affectedRows === 0) {
                        throw createHttpError(404, "Không tìm thấy dịch vụ");
                    }
                    return true;
                }
                case "food": {
                    const [result] = await database.query(
                        `CALL UpdateDichVuAnUong('${serviceId}', ${handleParameterIfNull(
                            price
                        )}, ${handleParameterIfNull(description)})`
                    );
                    if (result.affectedRows === 0) {
                        throw createHttpError(404, "Không tìm thấy dịch vụ");
                    }
                    return true;
                }
                case "meeting room": {
                    const [result] = await database.query(
                        `CALL UpdateDichVuPhongHop('${serviceId}', ${handleParameterIfNull(
                            roomCapacity
                        )}, ${handleParameterIfNull(price)}, ${handleParameterIfNull(description)})`
                    );
                    if (result.affectedRows === 0) {
                        throw createHttpError(404, "Không tìm thấy dịch vụ");
                    }
                    return true;
                }
                default: {
                    throw createHttpError(400, "Loại dịch vụ không hợp lệ");
                }
            }
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getAllRoomService(query) {
        let { type = "all", limit = 20, page = 1 } = query;
        try {
            switch (type) {
                case "laundry": {
                    const [result] = await database.query(`CALL GetAllDichVuGiatUi()`);
                    return result;
                }
                case "transport": {
                    const [result] = await database.query(`CALL GetAllDichVuDuaDon()`);
                    return result;
                }
                case "food": {
                    const [result] = await database.query(`CALL GetAllDichVuAnUong()`);
                    return result;
                }
                case "meeting room": {
                    const [result] = await database.query(`CALL GetAllDichVuPhongHop()`);
                    return result;
                }
                case "all": {
                    const [laundry] = await database.query(`CALL GetAllDichVuGiatUi()`);
                    const [transport] = await database.query(`CALL GetAllDichVuDuaDon()`);
                    const [food] = await database.query(`CALL GetAllDichVuAnUong()`);
                    const [meetingRooms] = await database.query(`CALL GetAllDichVuPhongHop()`);
                    return {
                        laundry: laundry[0],
                        transport: transport[0],
                        food: food[0],
                        meetingRoom: meetingRooms[0],
                    };
                }
            }
        } catch (error) {
            console.log(error);
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getRoomServiceInfo(query) {
        let { type, serviceId } = query;
        try {
            checkMissingField("type", type);
            checkMissingField("serviceId", serviceId);
            let QUERY = "";
            switch (type) {
                case "laundry": {
                    QUERY = `CALL GetDichVuGiatUiByID ('${serviceId}') `;
                    break;
                }
                case "transport": {
                    QUERY = `CALL GetDichVuDuaDonByID ('${serviceId}') `;
                    break;
                }
                case "food": {
                    QUERY = `CALL GetDichVuAnUongByID ('${serviceId}') `;
                    break;
                }
                case "meeting room": {
                    QUERY = `CALL GetDichVuPhongHopID ('${serviceId}') `;
                    break;
                }
                default: {
                    throw createHttpError(400, "Loại dịch vụ không hợp lệ");
                }
            }
            const [result] = await database.query(QUERY);
            // cái này do procedure trả về result[1] là metadata
            if (result.length > 0 && result[0].length > 0) {
                return result[0][0];
            } else {
                throw createHttpError(404, "Không tìm thấy dịch vụ");
            }
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getRoomServiceOrder(query) {
        let { orderId, type } = query;
        try {
            checkMissingField("type", type);
            checkMissingField("orderId", orderId);
            type = type.toLowerCase();
            let result = [];
            switch (type) {
                case "laundry": {
                    [result] = await database.query(`CALL GetDonSuDungDichVuGiatUiByID('${orderId}')`);
                    break;
                }
                case "transport": {
                    [result] = await database.query(`CALL GetDonSuDungDichVuDuaDonByID('${orderId}')`);
                    break;
                }
                case "food": {
                    [result] = await database.query(`CALL GetDonDatDichVuAnUongByID('${orderId}')`);
                    break;
                }
                case "meeting room": {
                    [result] = await database.query(`CALL GetDonSuDungDichVuPhongHopByID('${orderId}')`);
                    break;
                }
                default: {
                    throw createHttpError(400, "Loại dịch vụ không hợp lệ");
                }
            }
            if (result.length > 0 && result[0].length > 0) return result[0][0];
            throw createHttpError(404, "Không tìm thấy đơn đặt dịch vụ");
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async createServiceOrderForRoomRecord(body) {
        /*
            meeting room: startTime, finishTime
            laundry: weight
            transport: departure, destination, departureTime, distance
            food: quantity
        */
        let {
            roomId,
            createdAt,
            serviceId,
            status = "not completed",
            type,
            quantity,
            weight,
            destination,
            departure,
            departureTime,
            distance,
            startTime,
            finishTime,
        } = body;
        console.log(body);
        try {
            checkMissingField("type", type);
            checkMissingField("serviceId", serviceId);
            checkMissingField("roomId", roomId);
            checkMissingField("createdAt", createdAt);
            type = type.toLowerCase();
            if (weight) weight = parseFloat(weight);
            if (quantity) quantity = parseInt(quantity);
            if (distance) distance = parseInt(distance);
            const service = await this.getRoomServiceInfo({ type, serviceId });
            const newOrderId = generateUUIDV4();
            console.log(service);
            switch (type) {
                case "laundry": {
                    let totalBill = parseFloat(service.MucGia) * weight;
                    await database.query(
                        `CALL CreateDonSuDungDichVuGiatUi (
                        '${newOrderId}', 
                        '${serviceId}', 
                        '${roomId}', 
                        '${formatDate(new Date(createdAt), "yyyy-MM-dd HH:mm:ss")}', 
                        NOW(),
                        ${weight},
                        ${totalBill},
                        '${status}'
                        )`
                    );
                    return true;
                }
                case "transport": {
                    let totalBill = parseFloat(service.MucGia) * distance;
                    await database.query(
                        `CALL CreateDonSuDungDichVuDuaDon (
                        '${newOrderId}', 
                        '${serviceId}', 
                        '${roomId}', 
                        '${formatDate(new Date(createdAt), "yyyy-MM-dd HH:mm:ss")}', 
                        NOW(),
                        '${departure}',
                        '${destination}',
                        ${totalBill},
                        '${status}'
                        )`
                    );
                    return true;
                }
                case "food": {
                    let totalBill = parseFloat(service.MucGia) * quantity;

                    await database.query(`CALL CreateDonDatDichVuAnUong(
                        '${newOrderId}', 
                        '${serviceId}', 
                        '${roomId}', 
                        '${formatDate(new Date(createdAt), "yyyy-MM-dd HH:mm:ss")}', 
                        NOW(),
                        '${quantity}',
                        '${status}',
                        ${totalBill})`);
                    return true;
                }
                case "meeting room": {
                    let totalBill =
                        parseFloat(service.MucGia) *
                        differenceInHours(new Date(finishTime), new Date(startTime), {
                            roundingMethod: "ceil",
                        });
                    await database.query(
                        `CALL CreateDonSuDungDichVuPhongHop(   
                        '${newOrderId}', 
                        '${serviceId}', 
                        '${roomId}', 
                        '${formatDate(new Date(createdAt), "yyyy-MM-dd HH:mm:ss")}', 
                        NOW(),
                         '${formatDate(new Date(startTime), "yyyy-MM-dd HH:mm:ss")}',
                         '${formatDate(new Date(finishTime), "yyyy-MM-dd HH:mm:ss")}',
                         ${totalBill},
                         '${status}')`
                    );
                    return true;
                }
                default: {
                    throw createHttpError(400, "Loại dịch vụ không hợp lệ");
                }
            }
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async updateServiceOrderForRoomRecord(body) {
        /*
            meeting room: startTime, finishTime
            laundry: weight
            transport: departure, destination, departureTime, distance
            food: quantity
        */
        // only order that is "not completed" can be updated

        let {
            orderId,
            type,
            status,
            quantity,
            weight,
            destination,
            departure,
            departureTime,
            startTime,
            finishTime,
            distance,
        } = body;
        console.log(body);

        try {
            checkMissingField("type", type);
            checkMissingField("orderId", orderId);
            type = type.toLowerCase();
            if (weight) weight = parseFloat(weight);
            if (quantity) quantity = parseInt(quantity);
            if (distance) distance = parseInt(distance);
            const order = await this.getRoomServiceOrder({ orderId, type });
            // Check order status first
            if (order[0].TrangThai !== "not completed") {
                throw createHttpError(403, "Đơn đã hủy hoặc hoàn thành không thể được cập nhật");
            }
            // Get service info
            const service = await this.getRoomServiceInfo({ type, serviceId: order[0].MaDichVu });

            switch (type) {
                case "laundry": {
                    let totalBill = weight ? parseFloat(service.MucGia) * weight : null;
                    console.log(`CALL UpdateDonSuDungDichVuGiatUi (
                        '${orderId}', 
                        ${handleParameterIfNull(weight)},
                        ${handleParameterIfNull(totalBill)},
                        ${handleParameterIfNull(status)}
                        )`);
                    await database.query(
                        `CALL UpdateDonSuDungDichVuGiatUi (
                        '${orderId}', 
                        ${handleParameterIfNull(weight)},
                        ${handleParameterIfNull(totalBill)},
                        ${handleParameterIfNull(status)}
                        )`
                    );
                    return true;
                }
                case "transport": {
                    let totalBill = distance ? parseFloat(service.MucGia) * distance : null;
                    await database.query(
                        `CALL UpdateDonSuDungDichVuDuaDon (
                        '${orderId}', 
                        ${handleParameterIfNull(departure)},
                        ${handleParameterIfNull(destination)},
                        ${handleParameterIfNull(totalBill)},
                        ${handleParameterIfNull(status)}
                        )`
                    );
                    return true;
                }
                case "food": {
                    let totalBill = quantity ? parseFloat(service.MucGia) * quantity : null;
                    await database.query(`CALL UpdateDonDatDichVuAnUong(
                        '${orderId}', 
                        ${handleParameterIfNull(status)},
                        ${handleParameterIfNull(quantity)},
                        ${handleParameterIfNull(totalBill)})`);
                    return true;
                }
                case "meeting room": {
                    let totalBill =
                        parseFloat(service.MucGia) *
                        differenceInHours(
                            new Date(finishTime || order[0].ThoiGianKetThuc),
                            new Date(startTime || order[0].ThoiGianBatDau),
                            {
                                roundingMethod: "ceil",
                            }
                        );
                    await database.query(
                        `CALL UpdateDonSuDungDichVuPhongHop(   
                        '${orderId}', 
                        '${formatDate(new Date(startTime || order[0].ThoiGianBatDau), "yyyy-MM-dd HH:mm:ss")}',
                        '${formatDate(new Date(finishTime || order[0].ThoiGianKetThuc), "yyyy-MM-dd HH:mm:ss")}',
                        ${totalBill},
                        '${status}')`
                    );
                    return true;
                }
                default: {
                    throw createHttpError(400, "Loại dịch vụ không hợp lệ");
                }
            }
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async deleteServiceOrderForRoomRecord(query) {
        let { orderId, type } = query;

        try {
            const order = await this.getRoomServiceOrder(query);
            if (order.TrangThai === "completed") {
                throw createHttpError(403, "Không thể xóa đơn đã hoàn thành");
            }
            switch (type) {
                case "laundry": {
                    await database.query(`CALL DeleteDonSuDungDichVuGiatUi ('${orderId}')`);
                    return true;
                }
                case "transport": {
                    await database.query(`CALL DeleteDonSuDungDichVuDuaDon ('${orderId}')`);
                    return true;
                }
                case "food": {
                    await database.query(`CALL DeleteDonDatDichVuAnUong('${orderId}')`);
                    return true;
                }
                case "meeting room": {
                    await database.query(`CALL DeleteDonSuDungDichVuPhongHop('${orderId}')`);
                    return true;
                }
                default: {
                    throw createHttpError(400, "Loại dịch vụ không hợp lệ");
                }
            }
        } catch (error) {
            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        }
    }

    async getServiceOrderOfRoomRecord(query) {
        let { roomId, createdAt } = query;
        try {
            checkMissingField("roomId", roomId);
            checkMissingField("createdAt", createdAt);
            const [laundry] = await database.query(
                `CALL GetDonSuDungDichVuGiatUiByMaPhongAndThoiGianTaoBanGhiPhong('${roomId}', '${formatDateTime(
                    createdAt
                )}')`
            );
            const [transport] = await database.query(
                `CALL GetDonSuDungDichVuDuaDonByMaPhongAndThoiGianTaoBanGhiPhong('${roomId}', '${formatDateTime(
                    createdAt
                )}')`
            );
            const [food] = await database.query(
                `CALL GetDonDatDichVuAnUongByMaPhongAndThoiGianTaoBanGhiPhong('${roomId}', '${formatDateTime(
                    createdAt
                )}')`
            );
            const [meetingRooms] = await database.query(
                `CALL GetDonSuDungDichVuPhongHopByMaPhongAndThoiGianTaoBanGhiPhong('${roomId}', '${formatDateTime(
                    createdAt
                )}')`
            );
            return {
                laundry: laundry[0],
                transport: transport[0],
                food: food[0],
                meetingRoom: meetingRooms[0],
            };
        } catch (error) {
            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new RoomService();
