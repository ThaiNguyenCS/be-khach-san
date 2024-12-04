var express = require("express");
const router = express.Router();
const consumerGoodsService = require("../services/consumer_goods.service");

router.patch("/:id", async (req, res) => {
    try {
        const result = await consumerGoodsService.updateGoodInfo(null, req.params.id, req.body);
        res.status(200).send({ status: "success", message: "Cập nhật sản phẩm thành công", data: result });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.delete("/:id", async (req, res) => {
    try {
        const result = await consumerGoodsService.deleteGood(req.params.id);
        res.status(200).send({ status: "success", data: result });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

// Add new type of goods
router.post("/", async (req, res) => {
    try {
        const result = await consumerGoodsService.createNewGoodType(req.body);
        res.status(201).send({ status: "success", data: result });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

router.get("/", async (req, res) => {
    try {
        const result = await consumerGoodsService.getAllGoods(req.query);
        res.status(200).send({
            status: "success",
            data: result.data,
            limit: result.limit,
            page: result.page,
            total: result.total,
        });
    } catch (error) {
        res.status(error.status).send({ status: "failed", error: error.message });
    }
});

module.exports = router;
