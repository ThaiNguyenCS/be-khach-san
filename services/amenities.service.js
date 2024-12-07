const { database } = require("../database");
const { pushUpdate } = require("../utils/dynamicUpdate");
const { checkMissingField } = require("../utils/errorHandler");
const { generateUUIDV4 } = require("../utils/idManager");

class AmenityService {
    async getAllAmenitiesOfBranch (branchId)
    {
        try {
            const QUERY = `SELECT * TienNghiKhachSan WHERE MaChiNhanh`;
            console.log(QUERY);
            const [result] = await database.query(QUERY);
            return { result, message: "Thêm tiện nghi cho chi nhánh thành công!" };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async addAmenityForBranch(data) {
        let { name, description, branchId } = data;
        try {
            checkMissingField("name", name);
            checkMissingField("branchId", branchId);
            const newAmenityId = generateUUIDV4();
            const QUERY = `INSERT INTO TienNghiKhachSan (ID, Ten, MoTa, MaChiNhanh) 
            VALUES ('${newAmenityId}', '${name}', ${description ? `${description}` : "NULL"}, '${branchId}')`;
            console.log(QUERY);
            const [result] = await database.query(QUERY);
            return { result, message: "Thêm tiện nghi cho chi nhánh thành công!" };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async updateAmenityForBranch(id, data) {
        let { name, description, branchId } = data;
        try {
            const updates = [];
            pushUpdate(updates, "Ten", name ? `"${name}"` : null);
            pushUpdate(updates, "MoTa", description ? `"${description}"` : null);
            pushUpdate(updates, "MaChiNhanh", branchId ? `"${branchId}"` : null);
            if (updates.length > 0) {
                const QUERY = `UPDATE TienNghiKhachSan SET ${updates.join(", ")} WHERE ID = '${id}'`;
                console.log(QUERY);
                const [result] = await database.query(QUERY);
                return { result, message: "Sửa thông tin tiện nghi thành công!" };
            }
            throw createHttpError(400, "Cần có ít nhất 1 trường để cập nhật");
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async deleteAmenityFromBranch(id) {
        try {
            const QUERY = `DELETE FROM TienNghiKhachSan WHERE ID = '${id}'`;
            console.log(QUERY);
            const [result] = await database.query(QUERY);
            if (result.affectedRows === 0) {
                throw createHttpError(404, "Tiện nghi không tồn tại");
            }
            return { result, message: "Xóa thông tin tiện nghi thành công!" };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new AmenityService();
