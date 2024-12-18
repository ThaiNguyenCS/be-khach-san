const { format, compareAsc } = require("date-fns");
const createHttpError = require("http-errors");
const { database } = require("../database");
const { getDateArray, getDateArrayV2 } = require("../utils/date");
require("dotenv").config();
class ReportService {
    async getEmployeeSalaries(query) {
        let { period = "monthly", startTime = new Date(Date.now()), endTime = new Date(Date.now()) } = query;
        try {
            // cannot get salary daily
            if (period === "daily") period = "monthly";

            startTime = new Date(startTime);
            endTime = new Date(endTime);
            // invalid query
            if (compareAsc(endTime, startTime) === -1) {
                throw createHttpError(400, "endTime is before startTime");
            }
            let dateArr = [];
            const conditions = [];
            const selects = [];
            if (period === "monthly") {
                dateArr = getDateArrayV2(startTime, endTime, "month");
                console.log(dateArr);

                conditions.push(
                    `ThangCap IN  (${dateArr
                        .map((item) => `MONTH('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                conditions.push(
                    `NamCap IN  (${dateArr
                        .map((item) => `YEAR('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                selects.push(["ThangCap", "AS issuedMonth"]);
                selects.push([`NamCap`, "AS issuedYear"]);
            }
            if (period === "yearly") {
                dateArr = getDateArrayV2(startTime, endTime, "year");
                conditions.push(
                    `NamCap IN  (${dateArr
                        .map((item) => `YEAR('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                selects.push([`NamCap`, "AS issuedYear"]);
            }
            const QUERY = `SELECT SUM(MucLuong) as salary, ${selects
                .map((item) => item[0] + " " + item[1])
                .join(", ")} FROM LichSuCapLuong ${
                conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : ""
            } GROUP BY ${selects.map((item) => item[0]).join(", ")}`;
            const [result] = await database.query(QUERY);
            return { salary: { data: result, startTime: dateArr[0], endTime: dateArr.at(-1), period } };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getIntakeFromOrderedRooms(query) {
        let { period = "daily", startTime = new Date(Date.now()), endTime = new Date(Date.now()) } = query;
        try {
            startTime = new Date(startTime);
            endTime = new Date(endTime);
            // invalid query
            if (compareAsc(endTime, startTime) === -1) {
                throw createHttpError(400, "endTime is before startTime");
            }

            let dateArr = [];
            console.log("dateArr", dateArr);

            const conditions = [];
            const selects = [];
            if (period === "daily") {
                dateArr = getDateArrayV2(startTime, endTime, "date");
                conditions.push(
                    `DATE(ThoiGianTaoBanGhiPhong) IN (${dateArr
                        .map((item) => `'${format(new Date(item), "yyyy-MM-dd")}'`)
                        .join(", ")})`
                );
                selects.push([`DATE(ThoiGianTaoBanGhiPhong)`, "AS date"]);
            }
            if (period === "monthly") {
                dateArr = getDateArrayV2(startTime, endTime, "month");
                console.log(dateArr);

                conditions.push(
                    `MONTH(ThoiGianTaoBanGhiPhong) IN  (${dateArr
                        .map((item) => `MONTH('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                conditions.push(
                    `YEAR(ThoiGianTaoBanGhiPhong) IN  (${dateArr
                        .map((item) => `YEAR('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                selects.push(["MONTH(ThoiGianTaoBanGhiPhong)", "AS month"]);
                selects.push([`YEAR(ThoiGianTaoBanGhiPhong)`, "AS year"]);
            }
            if (period === "yearly") {
                dateArr = getDateArrayV2(startTime, endTime, "year");
                conditions.push(
                    `YEAR(ThoiGianTaoBanGhiPhong) IN  (${dateArr
                        .map((item) => `YEAR('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                selects.push([`YEAR(ThoiGianTaoBanGhiPhong)`, "AS year"]);
            }

            const QUERY = `SELECT SUM(GiaTien) as revenue, ${selects
                .map((item) => item[0] + " " + item[1])
                .join(", ")} FROM BanGhiPhong ${
                conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : ""
            } GROUP BY ${selects.map((item) => item[0]).join(", ")}`;
            console.log(QUERY);
            const [result] = await database.query(QUERY);
            return { roomRevenues: { data: result, period, startTime: dateArr[0], endTime: dateArr.at(-1) } };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getIntakeFromServices(query) {
        let { period = "daily", startTime = new Date(Date.now()), endTime = new Date(Date.now()) } = query;

        try {
            startTime = new Date(startTime);
            endTime = new Date(endTime);
            console.log(query);

            // invalid query
            if (compareAsc(endTime, startTime) === -1) {
                throw createHttpError(400, "endTime is before startTime");
            }

            let dateArr = [];

            const conditions = [];
            const selects = [];
            const results = [];

            if (period === "daily") {
                dateArr = getDateArrayV2(startTime, endTime, "date");
                conditions.push(
                    `DATE(ThoiGian) IN (${dateArr
                        .map((item) => `'${format(new Date(item), "yyyy-MM-dd")}'`)
                        .join(", ")})`
                );
                selects.push([`DATE(ThoiGian)`, "AS date"]);
            }
            if (period === "monthly") {
                dateArr = getDateArrayV2(startTime, endTime, "month");
                console.log(dateArr);

                conditions.push(
                    `MONTH(ThoiGian) IN  (${dateArr
                        .map((item) => `MONTH('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                conditions.push(
                    `YEAR(ThoiGian) IN  (${dateArr
                        .map((item) => `YEAR('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                selects.push(["MONTH(ThoiGian)", "AS month"]);
                selects.push([`YEAR(ThoiGian)`, "AS year"]);
            }
            if (period === "yearly") {
                dateArr = getDateArrayV2(startTime, endTime, "year");
                conditions.push(
                    `YEAR(ThoiGian) IN  (${dateArr
                        .map((item) => `YEAR('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                selects.push([`YEAR(ThoiGian)`, "AS year"]);
            }
            console.log("dateArr", dateArr);

            const tableNames = [
                process.env.SQL_TABLE_MeetingRoomOrder,
                process.env.SQL_TABLE_TransportOrder,
                process.env.SQL_TABLE_LaundryOrder,
                process.env.SQL_TABLE_FoodOrder,
            ];
            for (let i = 0; i < tableNames.length; i++) {
                const QUERY = `SELECT SUM(TongTien) as revenue, ${selects
                    .map((item) => item[0] + " " + item[1])
                    .join(", ")} FROM ${tableNames[i]} ${
                    conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : ""
                } GROUP BY ${selects.map((item) => item[0]).join(", ")}`;
                console.log(QUERY);
                const [result] = await database.query(QUERY);
                results.push({ [tableNames[i]]: result });
            }
            return { services: { data: results, startTime: dateArr[0], endTime: dateArr.at(-1), period } };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getMaintenanceCost(query) {
        let { period = "daily", startTime = new Date(Date.now()), endTime = new Date(Date.now()) } = query;
        try {
            startTime = new Date(startTime);
            endTime = new Date(endTime);
            console.log(query);

            // invalid query
            if (compareAsc(endTime, startTime) === -1) {
                throw createHttpError(400, "endTime is before startTime");
            }

            let dateArr = [];

            const conditions = [];
            const selects = [];
            const results = [];

            if (period === "daily") {
                dateArr = getDateArrayV2(startTime, endTime, "date");
                conditions.push(
                    `DATE(NgaySuaChua) IN (${dateArr
                        .map((item) => `'${format(new Date(item), "yyyy-MM-dd")}'`)
                        .join(", ")})`
                );
                selects.push([`DATE(NgaySuaChua)`, "AS date"]);
            }
            if (period === "monthly") {
                dateArr = getDateArrayV2(startTime, endTime, "month");
                console.log(dateArr);

                conditions.push(
                    `MONTH(NgaySuaChua) IN  (${dateArr
                        .map((item) => `MONTH('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                conditions.push(
                    `YEAR(NgaySuaChua) IN  (${dateArr
                        .map((item) => `YEAR('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                selects.push(["MONTH(NgaySuaChua)", "AS month"]);
                selects.push([`YEAR(NgaySuaChua)`, "AS year"]);
            }
            if (period === "yearly") {
                dateArr = getDateArrayV2(startTime, endTime, "year");
                conditions.push(
                    `YEAR(NgaySuaChua) IN  (${dateArr
                        .map((item) => `YEAR('${format(new Date(item), "yyyy-MM-dd")}')`)
                        .join(", ")})`
                );
                selects.push([`YEAR(NgaySuaChua)`, "AS year"]);
            }
            console.log("dateArr", dateArr);

            const tableNames = [process.env.SQL_TABLE_MaintenanceHistory];
            for (let i = 0; i < tableNames.length; i++) {
                const QUERY = `SELECT SUM(ChiPhi) as revenue, ${selects
                    .map((item) => item[0] + " " + item[1])
                    .join(", ")} FROM ${tableNames[i]} ${
                    conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : ""
                } GROUP BY ${selects.map((item) => item[0]).join(", ")}`;
                console.log(QUERY);
                const [result] = await database.query(QUERY);
                results.push({ [tableNames[i]]: result });
            }
            return { maintenances: { data: results, startTime: dateArr[0], endTime: dateArr.at(-1), period } };
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new ReportService();
