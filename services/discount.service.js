const createHttpError = require('http-errors');
const { checkMissingField } = require('../utils/errorHandler');
const { database } = require('../database');
const { format } = require('date-fns');
const { pushUpdate } = require('../utils/dynamicUpdate');
const { queryRef } = require('firebase/data-connect');

class DiscountService {
    async createDiscount(data) {
        let { discountId, startTime, finishTime, discountPercent } = data;

        try {
            checkMissingField('discountId', discountId);
            checkMissingField('startTime', startTime);
            checkMissingField('finishTime', finishTime);
            checkMissingField('discountPercent', discountPercent);
            discountPercent = parseInt(discountPercent);
            const QUERY = `INSERT INTO ChuongTrinhGiamGia (MaGiamGia, ThoiGianBatDau, ThoiGianKetThuc, PhanTramGiamGia) VALUES 
            ('${discountId}', 
            '${format(new Date(startTime), 'yyyy-MM-dd HH:mm:ss')}',
            '${format(new Date(finishTime), 'yyyy-MM-dd HH:mm:ss')}',
            ${discountPercent})`;
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async deleteDiscount(id) {
        try {
            const QUERY = `DELETE FROM ChuongTrinhGiamGia WHERE MaGiamGia = '${id}'`;
            const [result] = await database.query(QUERY);
            if (result.affectedRows === 0) {
                throw createHttpError(404, 'Khuyến mãi không tồn tại!');
            }
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async updateDiscount(id, data) {
        let { startTime, finishTime, discountPercent } = data;
        try {
            const updates = [];
            pushUpdate(
                updates,
                'ThoiGianBatDau',
                startTime ? `'${format(new Date(startTime), 'yyyy-MM-dd HH:mm:ss')}'` : null
            );

            pushUpdate(
                updates,
                'ThoiGianKetThuc',
                finishTime ? `'${format(new Date(finishTime), 'yyyy-MM-dd HH:mm:ss')}'` : null
            );

            pushUpdate(updates, 'PhanTramGiamGia', discountPercent ? parseInt(discountPercent) : null);
            if (updates.length > 0) {
                const QUERY = `UPDATE ChuongTrinhGiamGia SET ${updates.join(', ')} WHERE MaGiamGia = '${id}'`;
                const [result] = await database.query(QUERY);
                return result;
            }
            throw createHttpError(400, 'Vui lòng thêm ít nhất 1 trường cần cập nhật');
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }


    async getAllActiveDiscount(query) {
        let { limit = 20, page = 1, searchId } = query;
        try {
            limit = parseInt(limit);
            page = parseInt(page);
            let condition = '';
            if (searchId) {
                condition = `AND MaGiamGia LIKE '%${searchId}%'`;
            }
            const QUERY = `SELECT * FROM ChuongTrinhGiamGia WHERE NOW() <= ThoiGianKetThuc ${condition} LIMIT ${limit} OFFSET ${(page - 1) * limit}`;

            const COUNT_QUERY = `SELECT COUNT(*) as total FROM ChuongTrinhGiamGia WHERE NOW() <= ThoiGianKetThuc ${condition}`;
            const [result] = await database.query(QUERY);
            const [countResult] = await database.query(COUNT_QUERY);
            return {data: result, limit: limit, page: page, total: countResult[0].total};
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getDiscountById(id) {
        try {
            const QUERY = `SELECT * FROM ChuongTrinhGiamGia WHERE MaGiamGia = '${id}'`;
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new DiscountService();
