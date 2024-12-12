const createHttpError = require('http-errors')
const { database } = require('../database')
const { pushUpdate } = require('../utils/dynamicUpdate')

class BranchService {
    async getBranches () {
        try {
            const QUERY = `SELECT * FROM ChiNhanh`
            const [result] = await database.query(QUERY)
            return result
        } catch (error) {
            if(error.status)
                throw error
            throw createHttpError(500, error.message)
        }
    }

    async updateBranchInfo (id, data) {
        let {address, hotline } = data
        try {
            const updates = []
            pushUpdate(updates, 'DiaChi', address ? `'${address}'` : null)
            pushUpdate(updates, 'Hotline', hotline ? `'${hotline}'` : null)
            if(updates.length > 0)
            {
                const QUERY = `UPDATE ChiNhanh SET ${updates.join(', ')} WHERE MaChiNhanh = '${id}'`;
                const [result] = await database.query(QUERY)
                return result
            }
            throw createHttpError(400, 'Vui lòng chọn ít nhất 1 trường cần cập nhật!')
        } catch (error) {
            if(error.status)
                throw error
            throw createHttpError(500, error.message)
        }
    }
}

module.exports = new BranchService()