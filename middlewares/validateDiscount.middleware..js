const discountService = require("../services/discount.service");

async function validateDiscount(req, res, next) {
    let { discountId } = req.body;
    try {
        const result = await discountService.getDiscountById(discountId);
        if (result.length < 1) {
            return res.status(404).send({ status: "failed", message: "Không tìm thấy mã giảm giá" });
        }
        next()
    } catch (error) {
        res.status(500).send({ status: "failed", message: error.message });
    }
}

module.exports = {validateDiscount}