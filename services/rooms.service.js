const createHttpError = require("http-errors");
const { generateUUIDV4 } = require("../utils/idManager");
const { database } = require("../database");
const { formatDate, compareAsc, differenceInBusinessDays, differenceInCalendarDays } = require("date-fns");
const consumerGoodService = require("./consumer_goods.service");
const { checkMissingField } = require("../utils/errorHandler");
const { getDateArray } = require("../utils/date");
const discountService = require("./discount.service");
require("dotenv").config();
class RoomService {
    async generatePriceForAllRoomsInAMonth(data) {
        let { month, year, normalRoomMinPrice, normalRoomPublicPrice, vipRoomMinPrice, vipRoomPublicPrice } = data;
        try {
            checkMissingField("month", month);
            checkMissingField("year", year);
            checkMissingField("normalRoomMinPrice", normalRoomMinPrice);
            checkMissingField("normalRoomPublicPrice", normalRoomPublicPrice);
            checkMissingField("vipRoomMinPrice", vipRoomMinPrice);
            checkMissingField("vipRoomPublicPrice", vipRoomPublicPrice);
            month = parseInt(month);
            year = parseInt(year);
            normalRoomMinPrice = parseFloat(normalRoomMinPrice);
            normalRoomPublicPrice = parseFloat(normalRoomPublicPrice);
            vipRoomMinPrice = parseFloat(vipRoomMinPrice);
            vipRoomPublicPrice = parseFloat(vipRoomPublicPrice);
            const QUERY = `CALL InsertDailyPricesByRoomType (${month}, ${year}, ${normalRoomMinPrice}, ${normalRoomPublicPrice}, ${vipRoomMinPrice}, ${vipRoomPublicPrice})`;
            console.log(QUERY);
            const [result] = await database.query(QUERY);
            console.log(result);
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async deletePriceOfAllRoomsInAMonth(query) {
        let { month, year } = query;
        try {
            checkMissingField("month", month);
            checkMissingField("year", year);
            month = parseInt(month);
            year = parseInt(year);
            const QUERY = `CALL DeletePricesByMonth (${month}, ${year})`;
            console.log(QUERY);
            const [result] = await database.query(QUERY);
            console.log(result);
            return result;
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getAllRooms(query) {
        let { limit = 20, page = 1, branchId, status, type } = query;
        try {
            limit = parseInt(limit);
            page = parseInt(page);
            const condition = [];
            if (branchId) {
                condition.push(`MaChiNhanh = '${branchId}'`);
            }

            if (status) {
                condition.push(`TrangThai = '${status}'`);
            }
            if (type) {
                condition.push(`LoaiPhong = '${type}'`);
            }
            const QUERY = `SELECT * FROM Phong ${
                condition.length > 0 ? `WHERE ${condition.join(" AND ")}` : ""
            } LIMIT ${limit} OFFSET ${(page - 1) * limit}`;
            console.log(QUERY);
            const COUNT_QUERY = `SELECT COUNT(*) as total FROM Phong ${
                condition.length > 0 ? `WHERE ${condition.join(" AND ")}` : ""
            }`;
            console.log(COUNT_QUERY);
            const [result] = await database.query(QUERY);
            const [count] = await database.query(COUNT_QUERY);
            console.log(count);
            return { data: result, limit, page, total: count[0].total };
        } catch (error) {}
    }

    async _verifyRoomsForOrder(query) {
        let { startDate, endDate, roomIds } = query;
        try {
            checkMissingField("startDate", startDate);
            checkMissingField("endDate", endDate);
            checkMissingField("roomIds", roomIds);
            roomIds = JSON.parse(roomIds);
            if (roomIds.length > 0) {
                const condition = [];
                condition.push(`P.TrangThai != 'maintenance'`);
                condition;

                const QUERY = `
                        SELECT P.* FROM Phong P WHERE NOT EXISTS (
                        SELECT * FROM BanGhiPhong BG 
                        JOIN DonDatPhong DDP ON BG.MaDatPhong = DDP.MaDon
                        WHERE BG.MaPhong = P.MaPhong AND
                        DDP.TrangThaiDon != 'cancelled' AND 
                        DATE('${startDate}') <= DDP.NgayTraPhong AND
                        DATE('${endDate}') >= DDP.NgayNhanPhong
                        )
                        AND P.MaPhong IN (${roomIds.map((room) => `'${room}'`).join(", ")})
                        ${condition.length > 0 ? `AND ${condition.join(" AND ")}` : ""}
                        `;

                console.log(QUERY);
                const [result] = await database.query(QUERY);
                if (result.length !== roomIds.length) {
                    throw createHttpError(400, "Trong đơn đặt có phòng không có sẵn");
                }
                return result;
            } else {
                throw createHttpError(400, "Không có phòng nào được chọn");
            }
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getAvailableRoomsForPeriod(query) {
        let { startDate, endDate, branchId, limit = 20, page = 1 } = query;
        limit = parseInt(limit);
        page = parseInt(page);
        try {
            checkMissingField("startDate", startDate);
            checkMissingField("endDate", endDate);
            const condition = [];
            condition.push(`P.TrangThai != 'maintenance'`);
            if (branchId) {
                condition.push(`P.MaChiNhanh = '${branchId}'`);
            }
            let QUERY = `SELECT P.* FROM Phong P WHERE NOT EXISTS (
                SELECT * FROM BanGhiPhong BG 
                JOIN DonDatPhong DDP ON BG.MaDatPhong = DDP.MaDon
                WHERE BG.MaPhong = P.MaPhong AND
                DDP.TrangThaiDon != 'cancelled' AND 
                DATE('${startDate}') <= DDP.NgayTraPhong AND
                DATE('${endDate}') >= DDP.NgayNhanPhong)
                 ${condition.length > 0 ? `AND ${condition.join(" AND ")}` : ""}
                LIMIT ${limit}
                OFFSET ${limit * (page - 1)}`;

            let COUNT_QUERY = `SELECT COUNT(*) as total FROM Phong P WHERE NOT EXISTS (
                SELECT * FROM BanGhiPhong BG 
                JOIN DonDatPhong DDP ON BG.MaDatPhong = DDP.MaDon
                WHERE BG.MaPhong = P.MaPhong AND
                DDP.TrangThaiDon != 'cancelled' AND 
                DATE('${startDate}') <= DDP.NgayTraPhong AND
                DATE('${endDate}') >= DDP.NgayNhanPhong)
                 ${condition.length > 0 ? `AND ${condition.join(" AND ")}` : ""}`;

            const [result] = await database.query(QUERY);
            for (let i = 0; i < result.length; i++) {
                let SERVICE_QUERY = `SELECT TNP.Ten, TNP.Mota FROM TienNghiPhong_Phong TNP_P JOIN TienNghiPhong TNP ON
                TNP.ID = TNP_P.MaTienNghi WHERE MaPhong = '${result[i].MaPhong}'`;
                let FACILITIES_QUERY = `SELECT CSVCP.TenTrangBi, CSVCP.imageURL FROM CoSoVatChatPhong CSVCP WHERE MaPhong = '${result[i].MaPhong}'`;
                const [service] = await database.query(SERVICE_QUERY);
                const [facility] = await database.query(FACILITIES_QUERY);
                result[i].services = service;
                result[i].facilities = facility;
            }

            const [total] = await database.query(COUNT_QUERY);
            if (result.length > 0) {
                for (let i = 0; i < result.length; i++) {
                    const prices = await this.getPriceOfRoomForEachDay(result[i].MaPhong, startDate, endDate);
                    result[i].GiaPhong = prices;
                }
            }
            return { data: result, limit, page, total: total[0].total };
        } catch (error) {
            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        }
    }

    async addConsumerGoodToRoom(roomId, data) {
        let { goodId, quantity } = data;

        const connection = await database.getConnection();
        await connection.beginTransaction();
        try {
            checkMissingField("goodId", goodId);
            checkMissingField("quantity", quantity);
            const goodInRoom = await consumerGoodService.findGoodInRoom(roomId, goodId);
            const goodInWareHouse = await consumerGoodService.getGoodById(goodId);
            quantity = parseInt(quantity);

            // if this good is not in the room yet
            if (goodInRoom.length === 0) {
                const newQuantityInWareHouse = goodInWareHouse[0].SoLuong - quantity;
                if (newQuantityInWareHouse < 0) {
                    throw createHttpError(403, "Số lượng hàng trong kho không đủ để cấp");
                }
                await consumerGoodService.updateGoodInfo(connection, goodId, {
                    quantity: goodInWareHouse[0].SoLuong - quantity,
                });
                const ADD_TO_ROOM_QUERY = `INSERT INTO DoTieuDung_Phong (MaDoTieuDung, MaPhong, SoLuong)
                VALUES ('${goodId}', '${roomId}', ${quantity})`;
                await connection.query(ADD_TO_ROOM_QUERY);
            } else {
                const newQuantityInWareHouse = goodInWareHouse[0].SoLuong - (quantity - goodInRoom[0].SoLuong); // tổng - (chênh lệch giá trị mới và cũ trong phòng)
                if (newQuantityInWareHouse < 0) {
                    throw createHttpError(403, "Số lượng hàng trong kho không đủ để cấp");
                }
                await consumerGoodService.updateGoodInfo(connection, goodId, {
                    quantity: newQuantityInWareHouse,
                });
                const UPDATE_QUERY = `UPDATE DoTieuDung_Phong SET SoLuong = ${quantity} WHERE MaDoTieuDung = '${goodId}' AND MaPhong = '${roomId}'`;
                await connection.query(UPDATE_QUERY);
            }
            await connection.commit();

            return { message: "Cập nhật đồ tiêu dùng trong phòng thành công!" };
        } catch (error) {
            console.log(error);

            await connection.rollback();
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        } finally {
            connection.release();
        }
    }

    // use when receptionist accept the order
    async getPriceOfRoomInMonths(query) {
        let { roomId, months } = query;
        try {
            checkMissingField("roomId", roomId);
            checkMissingField("months", months);
            months = JSON.parse(months);

            let monthYearPairs = months.map((date) => [new Date(date).getMonth() + 1, new Date(date).getFullYear()]);
            // lấy các cặp tháng, năm unique
            monthYearPairs = Array.from(new Set(monthYearPairs.map((date) => JSON.stringify(date)))).map((dateStr) =>
                JSON.parse(dateStr)
            );
            console.log(monthYearPairs);
            if (monthYearPairs.length === 0) {
                throw createHttpError(400, "Vui lòng chọn (các) tháng để xem bảng giá");
            }
            const results = [];
            for (let i = 0; i < monthYearPairs.length; i++) {
                const QUERY = `CALL GetPriceOfRoomInMonth('${roomId}', ${monthYearPairs[i][0]},  ${monthYearPairs[i][1]})`;
                console.log(QUERY);
                const [result] = await database.query(QUERY);
                results.push({ month: monthYearPairs[i][0], year: monthYearPairs[i][1], data: result[0] });
            }
            return results;
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }

    async getTotalPriceOfRoom(roomId, startDate, endDate) {
        await this.getRoom(roomId);
        try {
            const prices = await this.getPriceOfRoomForEachDay(roomId, startDate, endDate);
            let total = 0;
            const totalDays = differenceInCalendarDays(new Date(endDate), new Date(startDate)) + 1;
            console.log(prices);
            console.log("totalDays", totalDays);

            if (!prices || prices.length !== totalDays) {
                throw createHttpError(403, "Bảng giá cho phòng bị thiếu, vui lòng cập nhật thêm");
            }
            if (prices.length)
                for (let i = 0; i < prices.length; i++) {
                    total += prices[i].GiaGiam ? prices[i].GiaGiam : prices[i].GiaCongBo;
                }
            return { GIATIEN: total };
        } catch (error) {
            if (!error.status) throw createHttpError(500, error.message);
            throw error;
        }
    }

    async getPriceOfRoomForEachDay(roomId, startDate, endDate) {
        const room = await this.getRoom(roomId);
        try {
            if (room.length > 0) {
                let dateArr = []; // 1 mang cac ngay duoc giam gia tu ngay bat dau toi ngay ket thuc
                let fStartDate = formatDate(startDate, "yyyy-MM-dd");
                let fEndDate = formatDate(endDate, "yyyy-MM-dd");
                const PRICE_QUERY = `SELECT * FROM BangGia WHERE MaPhong = '${roomId}' AND 
                ThoiGianBatDauApDung >= DATE('${fStartDate}') AND ThoiGianBatDauApDung <= DATE('${fEndDate}')`;
                // console.log(PRICE_QUERY);

                let [prices] = await database.query(PRICE_QUERY);
                let _discount = null;

                if (room[0].IDGiamGia) {
                    const { discount } = await this.getAndValidateRoomDiscount(room[0].MaPhong);
                    _discount = discount;
                    if (_discount) {
                        // filter ra nhung ngay duoc giam gia
                        dateArr = getDateArray(startDate, endDate);
                        dateArr = dateArr.filter(
                            (date) =>
                                compareAsc(new Date(_discount.ThoiGianBatDau), new Date(date)) !== 1 &&
                                compareAsc(new Date(date), new Date(_discount.ThoiGianKetThuc)) !== 1
                        );
                    }
                }
                // dateArr contains the date that has the discount
                if (prices.length > 0) {
                    prices = prices.map((price) => {
                        if (
                            dateArr.find(
                                (date) =>
                                    formatDate(new Date(date), "yyyy-MM-dd") ===
                                    formatDate(new Date(price.ThoiGianBatDauApDung), "yyyy-MM-dd")
                            )
                        ) {
                            return {
                                ThoiGianBatDauApDung: price.ThoiGianBatDauApDung,
                                ThoiGianKetThucApDung: price.ThoiGianKetThucApDung,
                                GiaCongBo: parseFloat(price.GiaCongBo),
                                GiaGiam: (price.GiaCongBo * _discount.PhanTramGiamGia) / 100,
                            };
                        } else {
                            return {
                                ThoiGianBatDauApDung: price.ThoiGianBatDauApDung,
                                ThoiGianKetThucApDung: price.ThoiGianKetThucApDung,
                                GiaCongBo: parseFloat(price.GiaCongBo),
                                GiaGiam: null,
                            };
                        }
                    });
                }
                return prices;
            }
        } catch (error) {
            console.log(error);
            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        }
    }

    async createRoomRecord(connection, roomIds, orderId) {
        if (connection) {
            const ORDER_QUERY = `SELECT * FROM DonDatPhong DDP WHERE DDP.MaDon = '${orderId}'`;
            const [order] = await connection.query(ORDER_QUERY);
            console.log(order);
            let ROOM_RECORD_ADD_QUERY = `INSERT INTO BanGhiPhong (MaPhong , ThoiGianTaoBanGhiPhong , MaDatPhong , GiaTien) VALUES`;
            try {
                for (let i = 0; i < roomIds.length; i++) {
                    const { GIATIEN } = await this.getTotalPriceOfRoom(
                        roomIds[i],
                        order[0].NgayNhanPhong,
                        order[0].NgayTraPhong
                    );

                    ROOM_RECORD_ADD_QUERY += `('${roomIds[i]}', NOW(), '${orderId}', ${GIATIEN}),`;
                }
                ROOM_RECORD_ADD_QUERY = ROOM_RECORD_ADD_QUERY.substring(0, ROOM_RECORD_ADD_QUERY.length - 1); // discard the last comma
                await connection.query(ROOM_RECORD_ADD_QUERY);
            } catch (error) {
                if (error.status) throw error;
                throw createHttpError(500, error.message);
            }
        } else {
            console.log("no connection");
            throw createHttpError(500, "Something's wrong");
        }
    }

    async updateRoomInfo(roomId, data) {
        let { status, description, housekeeperId, discountId, roomInChargePersonID, capacity, linkedRoomId } = data;
        try {
            const updates = [];
            if (status) {
                updates.push(`TrangThai = '${status}'`);
            }
            if (description) {
                updates.push(`MoTa = '${description}'`);
            }
            if (housekeeperId) {
                updates.push(`IDNhanVienDonPhong = '${housekeeperId}'`);
            }
            if (roomInChargePersonID) {
                updates.push(`IDNhanVienPhong = '${roomInChargePersonID}'`);
            }
            if (discountId) {
                updates.push(`IDGiamGia = '${discountId}'`);
            }
            if (capacity) {
                capacity = parseInt(capacity);
                updates.push(`SucChua = ${capacity}`);
            }
            if (linkedRoomId) {
                updates.push(`MaPhongLienKet = '${linkedRoomId}'`);
            }
            const UPDATE_QUERY = `UPDATE Phong SET ${updates.join(", ")} WHERE MaPhong = '${roomId}'`;
            const [result] = await database.query(UPDATE_QUERY);
            return result;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    // get order information for customer
    async getOrderForCustomer(orderId) {
        const ORDER_QUERY = `SELECT * FROM DonDatPhong DDP JOIN BanGhiPhong BGP ON DDP.MaDon = BGP.MaDatPhong
        WHERE DDP.MaDon = '${orderId}'`;
        const [result] = await database.query(ORDER_QUERY);
        return result;
    }

    async getOrder(orderId) {
        const ORDER_QUERY = `SELECT * FROM DonDatPhong DDP WHERE DDP.MaDon = '${orderId}'`;
        const [result] = await database.query(ORDER_QUERY);
        return result[0];
    }

    async updateOrderStatus(orderId, data) {
        let { action } = data;
        try {
            checkMissingField("action", action);
            if (action !== "refuse" && action !== "accept") {
                throw createHttpError(400, `action phải là refuse hoặc accept`);
            }
            const order = await this.getOrder(orderId);
            if (order) {
                if (order.TrangThai === "cancelled") {
                    throw createHttpError(403, "Order is cancelled, its status cannot be changed");
                } else {
                    let UPDATE_ORDER_QUERY = `UPDATE DonDatPhong SET TrangThaiDon = ${
                        action === "accept" ? `'confirmed'` : action === "refuse" ? `'cancelled'` : `'not confirmed'`
                    } WHERE MaDon = '${orderId}'`;
                    console.log(UPDATE_ORDER_QUERY);
                    const [result] = await database.query(UPDATE_ORDER_QUERY);
                    return result;
                }
            }
            throw createHttpError(404, "Không tìm thấy đơn đặt phòng");
        } catch (error) {
            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        }
    }

    async createRoom(data) {
        let { branchId, type, description, capacity, roomNumber } = data;

        if (!branchId) {
            throw createHttpError(400, "branchId is required");
        }

        if (!type) {
            throw createHttpError(400, "type is required");
        }

        if (!roomNumber) {
            throw createHttpError(400, "roomNumber is required");
        }
        roomNumber = parseInt(roomNumber);

        if (capacity) {
            capacity = parseInt(capacity);
        }

        try {
            const newRoomId = generateUUIDV4();
            const INSERT_ROOM_QUERY = `INSERT INTO Phong (MaPhong, MaChiNhanh, LoaiPhong, MoTa, SucChua, SoPhong)
            VALUES ('${newRoomId}', '${branchId}', '${type}', '${description}', ${capacity}, ${roomNumber})`;

            await database.query(INSERT_ROOM_QUERY);
            // if (process.env.NODE_ENV === "deployment") {
            //     if (type === "normal") await database.query(`CALL InsertPriceListFor30Days ('${newRoomId}', 500000)`);
            //     else await database.query(`CALL InsertPriceListFor30Days ('${newRoomId}', 1000000)`);
            // }
            return true;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    async alterRoomPrice(roomId, data) {
        let { minPrice, publicPrice, startDate, endDate } = data;
        if (!minPrice && !publicPrice) {
            throw createHttpError(400, "price is missing");
        }
        if (!startDate) {
            throw createHttpError(400, "startDate is missing");
        }

        try {
            if (!endDate) {
                endDate = startDate;
            }

            let fStartDate = formatDate(new Date(startDate), "yyyy-MM-dd");
            let fEndDate = formatDate(new Date(endDate), "yyyy-MM-dd");

            const updates = [];
            if (minPrice) {
                minPrice = parseFloat(minPrice);
                updates.push(`GiaThapNhat = ${minPrice}`);
            }

            if (publicPrice) {
                publicPrice = parseFloat(publicPrice);
                updates.push(`GiaCongBo = ${publicPrice}`);
            }

            const UPDATE_QUERY = `UPDATE BangGia SET ${updates.join(
                ", "
            )} WHERE MaPhong = '${roomId}' AND ThoiGianBatDauApDung >= DATE('${fStartDate}') AND ThoiGianBatDauApDung <= DATE('${fEndDate}')`;
            console.log(UPDATE_QUERY);

            const [result] = await database.query(UPDATE_QUERY);
            return result;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    async findReportOfRoomRecord(roomId, recordCreatedTime) {
        try {
            const record = await this.findRoomRecord(roomId, recordCreatedTime);
            console.log(record);
            if (record.length > 0 && record[0].IDBanBaoCao) {
                const REPORT_QUERY = `SELECT * FROM BanBaoCaoPhong WHERE ID = '${record[0].IDBanBaoCao}'`;
                console.log(REPORT_QUERY);

                const [report] = await database.query(REPORT_QUERY);

                const GOOD_USAGE_QUERY = `SELECT VPSD.*, DTD.TenSanPham FROM VatPhamSuDung VPSD LEFT JOIN DoTieuDung DTD ON DTD.ID = VPSD.ID WHERE MaBanBaoCaoPhong = '${record[0].IDBanBaoCao}'`;
                const [good_usages] = await database.query(GOOD_USAGE_QUERY);

                return { report, good_usages };
            } else return [];
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    async findRoomRecord(roomId, recordCreatedTime) {
        try {
            const QUERY = `SELECT * FROM BanGhiPhong WHERE MaPhong = '${roomId}' AND ThoiGianTaoBanGhiPhong = '${formatDate(
                new Date(recordCreatedTime),
                "yyyy-MM-dd HH:mm:ss"
            )}'`;
            console.log(QUERY);

            const [record] = await database.query(QUERY);
            return record;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    async getAllRoomRecords(roomId) {
        try {
            const QUERY = `SELECT * FROM BanGhiPhong WHERE MaPhong = '${roomId}'`;
            const [record] = await database.query(QUERY);
            return record;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    async updateRoomRecordInfo(connection, roomId, createdTime, data) {
        let { reportId } = data;
        const updates = [];
        if (reportId) {
            updates.push(`IDBanBaoCao = '${reportId}'`);
        }
        try {
            const QUERY = `UPDATE BanGhiPhong SET ${updates.join(", ")} 
            WHERE MaPhong = '${roomId}' AND ThoiGianTaoBanGhiPhong = '${formatDate(
                new Date(createdTime),
                "yyyy-MM-dd HH:mm:ss"
            )}'`;
            if (connection) {
                await connection.query(QUERY);
            } else {
                await database.query(QUERY);
            }
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    async generateReportForRoomRecord(roomId, recordCreatedTime, data) {
        // roomId vs recordCreatedTime is primary key of room record
        /*
            goods: [{
                goodId,
                quantity
            }]
            brokenFacilities: [{
                facilityId, 
                charge
            }]
         */

        let { goods = "[]", brokenFacilities = "[]" } = data;

        const connection = await database.getConnection();
        console.log("goods", goods);
        try {
            goods = JSON.parse(goods);
            brokenFacilities = JSON.parse(brokenFacilities);
            const record = await this.findRoomRecord(roomId, recordCreatedTime);
            if (record.length > 0) {
                if (record[0].IDBanBaoCao) {
                    // report existed, don't create
                    throw createHttpError(403, "Report for this room existed!");
                } else {
                    await connection.beginTransaction();
                    const newReportId = generateUUIDV4();
                    const CREATE_REPORT_QUERY = `INSERT INTO BanBaoCaoPhong (ID, ThoiGian) VALUES ('${newReportId}', NOW())`;
                    console.log(CREATE_REPORT_QUERY);
                    await connection.query(CREATE_REPORT_QUERY); // create report
                    await this.updateRoomRecordInfo(connection, roomId, recordCreatedTime, { reportId: newReportId }); // add report ID to room record
                    if (goods.length > 0) {
                        const usages = [];
                        const updates = [];
                        // get goods info from the warehouse
                        const retrievedGoods = await consumerGoodService.getGoodByIds(goods.map((item) => item.goodId));
                        // add total price for each used good
                        goods = goods.map((item) => ({
                            ...item,
                            price:
                                retrievedGoods.find((good) => good.ID === item.goodId).GiaBanDonVi *
                                parseInt(item.quantity),
                        }));
                        goods.forEach((item) => {
                            usages.push(
                                `('${item.goodId}', ${parseInt(item.quantity)}, ${item.price}, '${newReportId}')`
                            );
                            updates.push(
                                `WHEN MaDoTieuDung = '${item.goodId}' THEN SoLuong - ${parseInt(item.quantity)}`
                            );
                        });
                        const QUERY = `INSERT INTO VatPhamSuDung (ID, SoLuong, Gia, MaBanBaoCaoPhong)
                        VALUES ${usages.join(", ")}`;
                        console.log(QUERY);
                        await connection.query(QUERY);
                        const UPDATE_GOODS_IN_ROOM = `UPDATE DoTieuDung_Phong SET SoLuong = CASE
                        ${updates.join(" ")}
                        ELSE SoLuong
                        END
                        WHERE MaPhong = '${roomId}'`;
                        console.log(UPDATE_GOODS_IN_ROOM);
                        await connection.query(UPDATE_GOODS_IN_ROOM);
                    }
                    // if (brokenFacilities.length > 0) {
                    // }
                    await connection.commit();
                }
            } else {
                throw createHttpError(404, "Room record not found");
            }
        } catch (error) {
            await connection.rollback();
            if (error.status) {
                throw error;
            }
            throw createHttpError(500, error.message);
        } finally {
            connection.release();
        }
    }

    async applyDiscountToRoom(roomId, data) {
        let { discountId } = data;

        try {
            const UPDATE_QUERY = `UPDATE Phong SET IDGiamGia = '${discountId}' WHERE MaPhong = '${roomId}'`;
            const [result] = await database.query(UPDATE_QUERY);
            return result;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }

    async getAndValidateRoomDiscount(roomId) {
        const room = await this.getRoom(roomId);
        if (room[0].IDGiamGia) {
            const result = await discountService.getDiscountById(room[0].IDGiamGia);
            if (result.length > 0) {
                if (compareAsc(new Date(result[0].ThoiGianKetThuc), new Date(Date.now())) !== -1) {
                    // discount is still valid

                    return { discount: result[0] };
                }
            }
            const QUERY = `UPDATE Phong SET IDMaGiamGia = NULL WHERE MaPhong = '${roomId}'`;
            await database.query(QUERY);
        }

        return { discount: null };
    }

    async getRoom(roomId) {
        try {
            const QUERY = `SELECT * FROM Phong WHERE MaPhong = '${roomId}'`;
            const [result] = await database.query(QUERY);
            return result;
        } catch (error) {
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new RoomService();
