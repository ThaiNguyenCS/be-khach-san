var express = require("express");
const authService = require("../services/auth.service");
const { authenticateBearerToken } = require("../middlewares/authentication.middleware");
const router = express.Router();

router.patch("/user/profile", authenticateBearerToken, async (req, res) => {
    try {
        const result = await authService.updateProfile({ user: req.user, ...req.body });
        res.send({ status: "success", message: "Cập nhật thông tin thành công" });
    } catch (error) {
        console.log(error);
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.get("/user/profile", authenticateBearerToken, async (req, res) => {
    try {
        const result = await authService.getProfile(req.user);
        res.send({ status: "success", data: result });
    } catch (error) {
        console.log(error);
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.post("/user/register", async (req, res) => {
    try {
        const result = await authService.register(req.body);
        res.send({ status: "success", ...result, message: "Đăng ký thành công" });
    } catch (error) {
        console.log(error);
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

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
        const result = await authService.sendOTP(req.body);
        res.send({ status: "success", ...result });
    } catch (error) {
        console.log(error);

        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
