var express = require("express");
const authService = require("../services/auth.service");

const router = express.Router();


router.post("/user/login", async (req, res) => {
    try {
        const result = await authService.verifyOtp(req.body);
        res.send({ status: "success", ...result, message: "Xác thực thành công" });
    } catch (error) {
        console.log(error);

        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.post("/user", async (req, res) => {
    try {
        await authService.sendOTP(req.body);
        res.send({ status: "success", message: "OTP đã được gửi về email!" });
    } catch (error) {
        console.log(error);

        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
