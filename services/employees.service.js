const { formatDate } = require("date-fns");
const createHttpError = require("http-errors");
const { checkMissingField, checkMonthValue } = require("../utils/errorHandler");
const { generateUUIDV4 } = require("../utils/idManager");
const { database } = require("../database");
const { pushUpdate } = require("../utils/dynamicUpdate");

class EmployeeService {
    // tạo bảng lương
    async generateIssuedSalary(data) {
        let { month, year } = data;
        try {
            checkMissingField("month", month);
            checkMissingField("year", year);
            month = parseInt(month);
            year = parseInt(year);
            const QUERY = `CALL GenerateLichSuCapLuong (${month}, ${year})`;
            const [result] = await database.query(QUERY);
            return { data: result };
        } catch (error) {
            console.log(error);

            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getIssuedSalaryForAnEmp(data) {
        let { empId, month, year } = data;
        const QUERY = `SELECT * FROM LichSuCapLuong WHERE IDNhanVien = '${empId}' AND NamCap = ${year} AND ThangCap = ${month} LIMIT 1`;
        const [result] = await database.query(QUERY);
        if (result.length > 0) {
            return result[0];
        }
        return null;
    }

    // update lương trong bảng cấp lương
    async updateIssuedSalary(data) {
        let { empId, salary, status, month, year } = data;
        try {
            checkMissingField("month", month);
            checkMissingField("year", year);
            month = parseInt(month);
            year = parseInt(year);
            const issuedSalary = await this.getIssuedSalaryForAnEmp({ empId, month, year });
            if (issuedSalary && issuedSalary.TrangThai) {
                throw createHttpError(403, "Lương đã cấp không thể cập nhật");
            }
            const updates = [];
            if (salary) {
                salary = parseFloat(salary);
                updates.push(`MucLuong = ${salary}`);
            }
            if (status) {
                updates.push(`TrangThai = ${status === "paid" ? 1 : 0}`);
            }
            if (updates.length === 0) throw createHttpError(400, "Vui lòng chọn ít nhất 1 trường để cập nhật");
            const QUERY = `UPDATE LichSuCapLuong SET ${updates.join(
                ", "
            )} WHERE IDNhanVien = '${empId}' AND NamCap = ${year} AND ThangCap = ${month}`;
            const [result] = await database.query(QUERY);
            return { data: result };
        } catch (error) {
            console.log(error);
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    // xem bảng lương tháng
    async getIssuedSalary(query) {
        let { month = new Date(Date.now()).getMonth() + 1, year = new Date(Date.now()).getFullYear() } = query;
        try {
            month = parseInt(month);
            checkMonthValue(month);
            year = parseInt(year);
            const QUERY = `SELECT LSCL.*, NV.HoTen, NV.SoTaiKhoan, NV.VaiTro FROM LichSuCapLuong LSCL JOIN NhanVien NV ON LSCL.IDNhanVien = NV.ID WHERE ThangCap = ${month} AND NamCap = ${year}`;
            console.log(QUERY);
            const [result] = await database.query(QUERY);
            return { data: result };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async addEmployee(data) {
        let {
            name,
            sex,
            salary,
            dateOfBirth,
            ssn,
            citizenId,
            bankAccount,
            role = "Other",
            startWorkingDate,
            eduLevel,
            branchId,
        } = data;
        try {
            checkMissingField("name", name);
            checkMissingField("citizenId", citizenId);
            checkMissingField("dateOfBirth", dateOfBirth);
            checkMissingField("sex", sex);
            /*
                IN p_ID VARCHAR(50),
                IN p_HoTen VARCHAR(255),
                IN p_GioiTinh ENUM('Other', 'Male', 'Female'),
                IN p_Luong DECIMAL(18, 2),
                IN p_NgaySinh DATE,
                IN p_MaBHXH VARCHAR(15) ,
                IN p_CCCD VARCHAR(12),
                IN p_SoTaiKhoan VARCHAR(15) ,
                IN p_VaiTro ENUM('Manager', 'Receptionist', 'House Keeper', 'Room Employee', 'Other'),
                IN p_ThoiGianBatDauLamViec DATE ,
                IN p_TrinhDoHocVan VARCHAR(255),
                IN p_MaChiNhanh VARCHAR(50)
            */
            const newEmpId = generateUUIDV4();
            const QUERY = `CALL InsertNhanVien (   
            '${newEmpId}',
            '${name}', 
            '${sex}', 
            ${salary ? parseFloat(salary) : "NULL"}, 
            '${formatDate(new Date(dateOfBirth), "yyyy-MM-dd")}', 
            ${ssn ? `'${ssn}'` : "NULL"}, 
            '${citizenId}', 
            ${bankAccount ? `'${bankAccount}'` : "NULL"}, 
            '${role}', 
            ${startWorkingDate ? `'${startWorkingDate}'` : "NULL"}, 
            ${eduLevel ? `'${eduLevel}'` : "NULL"}, 
            ${branchId ? `'${branchId}'` : "NULL"})`;
            console.log(QUERY);

            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            console.log(error);

            if (error.status) {
                throw error;
            }

            throw createHttpError(500, error.message);
        }
    }

    async updateEmployee(empId, data) {
        let {
            name,
            sex,
            salary,
            dateOfBirth,
            ssn,
            citizenId,
            bankAccount,
            role,
            startWorkingDate,
            eduLevel,
            branchId,
        } = data;
        try {
            const updates = [];
            pushUpdate(updates, "HoTen", name ? `'${name}'` : null);
            pushUpdate(updates, "GioiTinh", sex ? `'${sex}'` : null);
            pushUpdate(updates, "Luong", salary ? parseFloat(salary) : null);
            pushUpdate(
                updates,
                "NgaySinh",
                dateOfBirth ? `'${formatDate(new Date(dateOfBirth), "yyyy-MM-dd")}'` : null
            );
            pushUpdate(updates, "MaBHXH", ssn ? `'${ssn}'` : null);
            pushUpdate(updates, "CCCD", citizenId ? `'${citizenId}'` : null);
            pushUpdate(updates, "SoTaiKhoan", bankAccount ? `'${bankAccount}'` : null);
            pushUpdate(updates, "VaiTro", role ? `'${role}'` : null);
            pushUpdate(
                updates,
                "ThoiGianBatDauLamViec",
                startWorkingDate ? `'${formatDate(new Date(startWorkingDate), "yyyy-MM-dd")}'` : null
            );
            pushUpdate(updates, "TrinhDoHocVan", eduLevel ? `'${eduLevel}'` : null);
            pushUpdate(updates, "MaChiNhanh", branchId ? `'${branchId}'` : null);
            if (updates.length > 0) {
                const QUERY = `UPDATE NhanVien SET ${updates.join(", ")} WHERE ID = '${empId}'`;
                const [result] = await database.query(QUERY);
                if (result.affectedRows === 0) {
                    // not modified
                    throw createHttpError(404, "Không tìm thấy nhân viên");
                }
                return result;
            } // no fields to update
            else {
                throw createHttpError(403, "Hãy nhập các trường cần cập nhật");
            }
        } catch (error) {
            console.log(error);

            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        }
    }

    async deleteEmployee(empId) {
        try {
            const QUERY = `DELETE FROM NhanVien WHERE ID = '${empId}'`;
            const [result] = await database.query(QUERY);
            if (result.affectedRows === 0) {
                throw createHttpError(404, "Nhân viên không tồn tại");
            }
        } catch (error) {
            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        }
    }

    async getEmployeeById(empId) {}

    async getAllEmployees(query) {
        let { limit = 20, page = 1, role, name } = query;
        try {
            limit = parseInt(limit);
            page = parseInt(page);
            const condition = [];
            if (role) {
                condition.push(`VaiTro = '${role}'`);
            }

            if (name) {
                condition.push(`HoTen LIKE '%${name}%'`);
            }
            const QUERY = `SELECT * FROM NhanVien ${
                condition.length > 0 ? `WHERE ${condition.join(" AND ")}` : ""
            }  LIMIT ${limit} OFFSET ${(page - 1) * limit}`;

            const COUNT_QUERY = `SELECT COUNT(*) as total FROM NhanVien ${
                condition.length > 0 ? `WHERE ${condition.join(" AND ")}` : ""
            }`;
            const [result] = await database.query(QUERY);
            const [count] = await database.query(COUNT_QUERY);
            return { data: result, limit, page, total: count[0].total };
        } catch (error) {
            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new EmployeeService();
