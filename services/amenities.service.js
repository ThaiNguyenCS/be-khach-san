const createHttpError = require('http-errors');
const { database } = require('../database');
const { pushUpdate } = require('../utils/dynamicUpdate');
const { checkMissingField } = require('../utils/errorHandler');
const { generateUUIDV4 } = require('../utils/idManager');

class AmenityService {
    async getAllRoomAmenities(query) {
        let { limit = 20, page = 1, name } = query;
        try {
            limit = parseInt(limit);
            page = parseInt(page);
            const condition = [];
            if (name) {
                condition.push(`Ten LIKE '%${name}%'`);
            }
            const QUERY = `SELECT * FROM TienNghiPhong ${
                condition.length > 0 ? `WHERE ${condition.join('AND')}` : ''
            } LIMIT ${limit} OFFSET ${(page - 1) * limit}`;

            const COUNT_QUERY = `SELECT COUNT(*) as total FROM TienNghiPhong ${
                condition.length > 0 ? `WHERE ${condition.join('AND')}` : ''
            }`;
            const [result] = await database.query(QUERY);
            const [count] = await database.query(COUNT_QUERY);
            return { data: result, limit, page, total: count[0].total };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getAllAmenitiesOfBranch(query) {
        let { limit = 20, page = 1, branchId, name } = query;
        try {
            limit = parseInt(limit);
            page = parseInt(page);
            const condition = [];
            if (branchId) {
                condition.push(`MaChiNhanh = '${branchId}'`);
            }

            if (name) {
                condition.push(`Ten LIKE '%${name}%'`);
            }
            const QUERY = `SELECT * FROM TienNghiKhachSan ${
                condition.length > 0 ? `WHERE ${condition.join(' AND ')}` : ''
            } LIMIT ${limit} OFFSET ${(page - 1) * limit}`;

            const COUNT_QUERY = `SELECT COUNT(*) as total FROM TienNghiKhachSan ${
                condition.length > 0 ? `WHERE ${condition.join(' AND ')}` : ''
            }`;

            const [result] = await database.query(QUERY);
            const [count] = await database.query(COUNT_QUERY);
            return { data: result, limit: limit, page: page, total: count[0].total };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async addAmenityForBranch(data) {
        let { name, description, branchId } = data;
        try {
            checkMissingField('name', name);
            checkMissingField('branchId', branchId);
            const newAmenityId = generateUUIDV4();
            const QUERY = `INSERT INTO TienNghiKhachSan (ID, Ten, MoTa, MaChiNhanh) 
            VALUES ('${newAmenityId}', '${name}', ${description ? `'${description}'` : 'NULL'}, '${branchId}')`;
            console.log(QUERY);
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async updateAmenityForBranch(id, data) {
        let { name, description, branchId } = data;
        try {
            const updates = [];
            pushUpdate(updates, 'Ten', name ? `'${name}'` : null);
            pushUpdate(updates, 'MoTa', description ? `'${description}'` : null);
            pushUpdate(updates, 'MaChiNhanh', branchId ? `'${branchId}'` : null);
            if (updates.length > 0) {
                const QUERY = `UPDATE TienNghiKhachSan SET ${updates.join(', ')} WHERE ID = '${id}'`;
                console.log(QUERY);
                const [result] = await database.query(QUERY);
                return result;
            }
            throw createHttpError(400, 'Cần có ít nhất 1 trường để cập nhật');
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
                throw createHttpError(404, 'Tiện nghi không tồn tại');
            }
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
    async getAmenitiesStatistics() {
        try {
            const QUERY = `
                SELECT 
                    TienNghiPhong.Ten AS TienNghi,
                    COUNT(DISTINCT TienNghiPhong_Phong.MaPhong) AS SoLuongPhong
                FROM 
                    TienNghiPhong
                LEFT JOIN 
                    TienNghiPhong_Phong 
                ON 
                    TienNghiPhong.ID = TienNghiPhong_Phong.MaTienNghi
                GROUP BY 
                    TienNghiPhong.Ten;
            `;
            
            const [result] = await database.query(QUERY);
    
            if (result.length === 0) {
                throw createHttpError(404, 'Không tìm thấy tiện nghi nào trong các phòng');
            }
    
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
    async getAmenitiesStatisticsbyBranch(maChiNhanh = null) {
        try {
            // SQL query để thống kê số lượng phòng có mỗi loại tiện nghi
            let QUERY = `
                SELECT 
                    TienNghiPhong.Ten AS TienNghi,
                    COUNT(DISTINCT TienNghiPhong_Phong.MaPhong) AS SoLuongPhong
                FROM 
                    TienNghiPhong
                LEFT JOIN 
                    TienNghiPhong_Phong 
                ON 
                    TienNghiPhong.ID = TienNghiPhong_Phong.MaTienNghi
                LEFT JOIN
                    Phong
                ON
                    TienNghiPhong_Phong.MaPhong = Phong.MaPhong
            `;
            
            if (maChiNhanh) {
                QUERY += ` WHERE Phong.MaChiNhanh = ? `;
            }
    
            QUERY += 'GROUP BY TienNghiPhong.Ten;';
    
            const [result] = await database.query(QUERY, maChiNhanh ? [maChiNhanh] : []);
    
            if (result.length === 0) {
                throw createHttpError(404, 'Không tìm thấy tiện nghi nào trong các phòng');
            }
    
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new AmenityService();
