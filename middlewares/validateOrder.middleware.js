const bookingService = require("../services/booking.service");

const validateOrder = async (req, res, next) => {
    try {
        const { order, rooms } = await bookingService.getOrderById(req.params.orderId);
        
    } catch (error) {}
};

module.exports = { validateOrder };
