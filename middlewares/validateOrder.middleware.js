const bookingService = require("../services/booking.service");
const room_serviceService = require("../services/room_service.service");
const roomsService = require("../services/rooms.service");

const validateOrder = async (req, res, next) => {
    try {
        // Lấy order và check tồn tại
        const { order, rooms } = await bookingService.getOrderById(req.params.orderId);
        console.log(order);
        console.log("rooms", rooms);

        if (order.TrangThaiDon !== "confirmed") {
            return res.status(403).send({
                status: "failed",
                message: `Đơn đặt phòng chưa được xác nhận, không thể tạo hóa đơn`,
            });
        }
        // Check xem các phòng đã đầy đủ báo cáo hay chưa
        // const promises = [];
        for (let i = 0; i < rooms.length; i++) {
            const report = await roomsService.findReportOfRoomRecord(rooms[i].MaPhong, rooms[i].ThoiGianTaoBanGhiPhong);
            if (!report.report) {
                return res.status(403).send({
                    status: "failed",
                    message: `Bản ghi phòng (${rooms[i].MaPhong}, ${rooms[i].ThoiGianTaoBanGhiPhong}) chưa có báo cáo. Không thể checkout`,
                });
            }
            const services = await room_serviceService.getServiceOrderOfRoomRecord({
                roomId: rooms[i].MaPhong,
                createdAt: rooms[i].ThoiGianTaoBanGhiPhong,
            });
            // Cập nhật hoàn thành các đơn laundry
            if (services.laundry.length > 0) {
                for (let j = 0; j < services.laundry.length; j++) {
                    if (services.laundry[j].TrangThai === "not completed") {
                        // promises.push(
                        //     room_serviceService.updateServiceOrderForRoomRecord({
                        //         type: "laundry",
                        //         orderId: services.laundry[j].MaDon,
                        //         status: "completed",
                        //     })
                        // );
                        return res.status(403).send({
                            status: "failed",
                            message: `Bản ghi phòng (${rooms[i].MaPhong}, ${rooms[i].ThoiGianTaoBanGhiPhong}) có đơn đặt dịch vụ giặt ủi mã ${services.laundry[j].MaDon} chưa hoàn thành. Vui lòng cập nhật đơn trước khi checkout`,
                        });
                    }
                }
            }
            // Cập nhật hoàn thành các đơn food
            if (services.food.length > 0) {
                for (let j = 0; j < services.food.length; j++) {
                    if (services.food[j].TrangThai === "not completed") {
                        // promises.push(
                        //     room_serviceService.updateServiceOrderForRoomRecord({
                        //         type: "food",
                        //         orderId: services.food[j].MaDon,
                        //         status: "completed",
                        //     })
                        // );
                        return res.status(403).send({
                            status: "failed",
                            message: `Bản ghi phòng (${rooms[i].MaPhong}, ${rooms[i].ThoiGianTaoBanGhiPhong}) có đơn đặt dịch vụ ăn uống mã ${services.food[j].MaDon} chưa hoàn thành. Vui lòng cập nhật đơn trước khi checkout`,
                        });
                    }
                }
            }
            // Cập nhật hoàn thành các đơn transport
            if (services.transport.length > 0) {
                for (let j = 0; j < services.transport.length; j++) {
                    if (services.transport[j].TrangThai === "not completed") {
                        // promises.push(
                        //     room_serviceService.updateServiceOrderForRoomRecord({
                        //         type: "transport",
                        //         orderId: services.transport[j].MaDon,
                        //         status: "completed",
                        //     })
                        // );
                        return res.status(403).send({
                            status: "failed",
                            message: `Bản ghi phòng (${rooms[i].MaPhong}, ${rooms[i].ThoiGianTaoBanGhiPhong}) có đơn đặt dịch vụ đưa đón mã ${services.transport[j].MaDon} chưa hoàn thành. Vui lòng cập nhật đơn trước khi checkout`,
                        });
                    }
                }
            }
            // Cập nhật hoàn thành các đơn meeting room
            if (services.meetingRoom.length > 0) {
                for (let j = 0; j < services.meetingRoom.length; j++) {
                    if (services.meetingRoom[j].TrangThai === "not completed") {
                        // promises.push(
                        //     room_serviceService.updateServiceOrderForRoomRecord({
                        //         type: "meeting room",
                        //         orderId: services.meetingRoom[i].MaDon,
                        //         status: "completed",
                        //     })
                        // );
                        return res.status(403).send({
                            status: "failed",
                            message: `Bản ghi phòng (${rooms[i].MaPhong}, ${rooms[i].ThoiGianTaoBanGhiPhong}) có đơn đặt dịch vụ phòng họp mã ${services.meetingRoom[j].MaDon} chưa hoàn thành. Vui lòng cập nhật đơn trước khi checkout`,
                        });
                    }
                }
            }
        }
        console.log("here");
        
        // Lưu thay đổi tất cả các cập nhật
        // await Promise.all(promises);
        next();
        // Check xem các đơn đặt dịch vụ phòng đã completed hay chưa
    } catch (error) {
        return res.status(error.status || 500).send({ status: "failed", message: error.message });
    }
};

module.exports = { validateOrder };
