const { formatDate } = require("date-fns");
const createHttpError = require("http-errors");
const { checkMissingField } = require("../utils/errorHandler");
const { generateUUIDV4 } = require("../utils/idManager");
const { database } = require("../database");
const { pushUpdate } = require("../utils/dynamicUpdate");

class EmployeeService {
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
            pushUpdate(updates, "NgaySinh", dateOfBirth ? `'${formatDate(new Date(dateOfBirth), "yyyy-MM-dd")}'` : null);
            pushUpdate(updates, "MaBHXH", ssn ? `'${ssn}'` : null);
            pushUpdate(updates, "CCCD", citizenId ? `'${citizenId}'` : null);
            pushUpdate(updates, "SoTaiKhoan", bankAccount ? `'${bankAccount}'` : null);
            pushUpdate(updates, "VaiTro", role ? `'${role}'` : null);
            pushUpdate(updates, "ThoiGianBatDauLamViec", startWorkingDate ? `'${formatDate(new Date(startWorkingDate), "yyyy-MM-dd")}'` : null);
            pushUpdate(updates, "TrinhDoHocVan", eduLevel ? `'${eduLevel}'` : null);
            pushUpdate(updates, "MaChiNhanh", branchId ? `'${branchId}'` : null);
            if (updates.length > 0) {
                const QUERY = `UPDATE NhanVien SET ${updates.join(", ")} WHERE ID = '${empId}'`;
                const [result] = await database.query(QUERY)
                if(result.affectedRows === 0) // not modified
                {
                    throw createHttpError(404, "Không tìm thấy nhân viên");       
                }
                return result
            }
            else // no fields to update
            {
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
            if(result.affectedRows === 0)
            {
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

    async getAllEmployees(query) {}
}

module.exports = new EmployeeService();
