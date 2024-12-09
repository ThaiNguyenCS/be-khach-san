var express = require("express");
const discountService = require("../services/discount.service");
const router = express.Router();

router.get("/all", async (req, res) => {
    try {
        const result = await discountService.getAllActiveDiscount(req.query);
        res.send({ status: "success", data: result.data, limit: result.limit, page: result.page, total: result.total });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.post("/", async (req, res) => {
    try {
        const result = await discountService.createDiscount(req.body);
        res.status(201).send({ status: "success", message: "Tạo đối tượng khuyến mãi thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.patch("/:id", async (req, res) => {
    try {
        const result = await discountService.updateDiscount(req.params.id, req.body);
        res.send({ status: "success", data: result, message: "Cập nhật khuyến mãi thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.delete("/:id", async (req, res) => {
    try {
        await discountService.deleteDiscount(req.params.id);
        res.send({ status: "success", message: "Xóa khuyến mãi thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
