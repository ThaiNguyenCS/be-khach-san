const createHttpError = require("http-errors");
const { database } = require("../database");

class CustomerService {
    async getAllCustomers() {}
    async findCustomerByPhoneNumber(phoneNumber) {
        try {
            const QUERY = `SELECT * FROM KhachHang WHERE SoDienThoai = '${phoneNumber}' LIMIT 1`;
            const [result] = await database.query(QUERY);
            console.log(result);
            return result[0];
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new CustomerService();
