var express = require("express");
const employeesService = require("../services/employees.service");
const router = express.Router();

router.get("/all", async (req, res) => {
    try {
        const result = await employeesService.getAllEmployees(req.query);
        res.send({ status: "success", data: result.data, limit: result.limit, page: result.page, total: result.total });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.get("/all/salary", async (req, res) => {
    try {
        const result = await employeesService.getIssuedSalary(req.query);
        res.send({
            status: "success",
            ...result,
        });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.post("/all/salary", async (req, res) => {
    try {
        const result = await employeesService.generateIssuedSalary(req.body);
        res.send({
            status: "success",
            message: `Tạo bảng lương cho tháng ${req.body.month}/${req.body.year} thành công`,
        });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.patch("/:empId/salary", async (req, res) => {
    try {
        const result = await employeesService.updateIssuedSalary({ empId: req.params.empId, ...req.body });
        res.send({
            status: "success",
            message: `Cập nhật thông tin bảng lương cho nhân viên ${req.params.empId} thành công`,
        });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.get("/:empId", async (req, res) => {
    try {
        const result = await employeesService.getEmployeeById(req.params.empId);
        res.send({ status: "success", data: result });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.patch("/:empId", async (req, res) => {
    try {
        const result = await employeesService.updateEmployee(req.params.empId, req.body);
        res.send({ status: "success", data: result, message: "Cập nhật thông tin nhân viên thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

router.delete("/:empId", async (req, res) => {
    try {
        await employeesService.deleteEmployee(req.params.empId);
        res.send({ status: "success", message: "Xóa nhân viên thành công" });
    } catch (error) {
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});
router.post("/", async (req, res) => {
    try {
        const result = await employeesService.addEmployee(req.body);
        res.send({ status: "success", message: "Thêm nhân viên thành công" });
    } catch (error) {
        console.log(error);
        res.status(error.status).send({ status: "failed", message: error.message });
    }
});

module.exports = router;
