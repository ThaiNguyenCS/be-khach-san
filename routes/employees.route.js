var express = require("express")
const employeesService = require("../services/employees.service")
const router = express.Router()

router.get("/:empId", async (req, res) => {
    try {
        const result = await employeesService.getEmployeeById(req.params.empId);
        res.send({status: "success", data: result})
    } catch (error) {
        res.status(error.status).send({status: "failed", message: error.message})
    }
})

router.patch("/:empId", async (req, res) => {
    try {
        const result = await employeesService.updateEmployee(req.params.empId, req.body);
        res.send({status: "success", data: result, message: 'Cập nhật thông tin nhân viên thành công'})
    } catch (error) {
        res.status(error.status).send({status: "failed", message: error.message})
    }
})

router.delete("/:empId", async (req, res) => {
    try {
        await employeesService.deleteEmployee(req.params.empId)
        res.send({status: "success", message: "Xóa nhân viên thành công"})
    } catch (error) {
        res.status(error.status).send({status: "failed", message: error.message})
    }
})
router.post("/", async (req, res) => {
    try {
        const result = await employeesService.addEmployee(req.body);
        res.send({status: "success", message: "Thêm nhân viên thành công"})
    } catch (error) {
        console.log(error);
        res.status(error.status).send({status: "failed", message: error.message})
    }

})




module.exports = router