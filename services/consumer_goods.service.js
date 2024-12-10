const createHttpError = require("http-errors");
const { database } = require("../database");
const { checkMissingField } = require("../utils/errorHandler");
const { generateUUIDV4 } = require("../utils/idManager");

class ConsumerGoodService {
    async findGoodsInRoom(roomId) {
        try {
            const QUERY = `SELECT * FROM DoTieuDung_Phong WHERE MaPhong = '${roomId}'`;
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }

    async findGoodInRoom(roomId, goodId) {
        try {
            const QUERY = `SELECT * FROM DoTieuDung_Phong WHERE MaPhong = '${roomId}' AND MaDoTieuDung = '${goodId}'`;
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }

    async getGoodById(goodId) {
        try {
            const QUERY = `SELECT * FROM DoTieuDung WHERE ID = '${goodId}'`;
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }

    async getGoodByIds(goodIds) {
        try {
            const QUERY = `SELECT * FROM DoTieuDung WHERE ID IN (${goodIds.map((item) => `'${item}'`).join(",")})`;
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }

    async getAllGoods(query) {
        let { limit = 20, page = 1, search } = query; // search for regex in good name
        try {
            limit = parseInt(limit);
            page = parseInt(page);

            let WHERE = "";
            if (search) {
                WHERE = `WHERE TenSanPham LIKE '%${search}%'`;
            }
            let QUERY = `SELECT * FROM DoTieuDung ${WHERE} LIMIT ${limit} OFFSET ${(page - 1) * limit}`;
            console.log(QUERY);
            const COUNT_QUERY = `SELECT COUNT(*) AS Total FROM DoTieuDung`;
            const [result] = await database.query(QUERY);
            const [total] = await database.query(COUNT_QUERY);
            return { data: result, limit, page, total: total[0].Total };
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }

    async updateGoodInfo(connection, id, data) {
        // Update quantity, 2 types of price
        console.log(data);
        let { quantity, importPricePerUnit, salePricePerUnit } = data;
        try {
            if (!quantity && !importPricePerUnit && !salePricePerUnit) {
                throw createHttpError(400, "No fields are specified");
            }
            const updates = [];
            if (quantity) {
                quantity = parseInt(quantity);
                updates.push(`SoLuong = ${quantity}`);
            }
            if (importPricePerUnit) {
                importPricePerUnit = parseFloat(importPricePerUnit);
                updates.push(`GiaNhapDonVi = ${importPricePerUnit}`);
            }
            if (salePricePerUnit) {
                salePricePerUnit = parseFloat(salePricePerUnit);
                updates.push(`GiaBanDonVi = ${salePricePerUnit}`);
            }
            const UPDATE_QUERY = `UPDATE DoTieuDung SET ${updates.join(", ")} WHERE ID = '${id}'`;
            let result = null;
            // use connection as a part of a transaction
            if (connection) {
                const [result] = await connection.query(UPDATE_QUERY);
            } else {
                const [result] = await database.query(UPDATE_QUERY);
            }
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async createNewGoodType(data) {
        let { goodName, quantity = 0, importPricePerUnit, salePricePerUnit } = data;
        try {
            checkMissingField("goodName", goodName);
            checkMissingField("importPricePerUnit", importPricePerUnit);
            checkMissingField("salePricePerUnit", salePricePerUnit);
            importPricePerUnit = parseFloat(importPricePerUnit);
            salePricePerUnit = parseFloat(salePricePerUnit);
            quantity = parseInt(quantity);
            const newId = generateUUIDV4();
            const CREATE_QUERY = `INSERT INTO DoTieuDung (ID, TenSanPham, SoLuong, GiaNhapDonVi, GiaBanDonVi) 
            VALUES ('${newId}', '${goodName}', ${quantity}, ${importPricePerUnit}, ${salePricePerUnit})`;
            const [result] = await database.query(CREATE_QUERY);
            return result;
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }

    async deleteGood(id) {
        try {
            const QUERY = `DELETE FROM DoTieuDung WHERE ID = '${id}'`;
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }
}

module.exports = new ConsumerGoodService();
