const createHttpError = require("http-errors");
const { database } = require("../database");
const { checkMissingField } = require("../utils/errorHandler");
const { handleParameterIfNull } = require("../utils/sqlParamHandler");
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
}

module.exports = new RoomService();
