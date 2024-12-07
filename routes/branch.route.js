var express = require("express")
const branchService = require("../services/branch.service")
const router = express.Router()

router.patch("/:branchId", async (req, res) => {
    try {
        const result = await branchService.updateBranchInfo(req.params.branchId, req.body)
        res.send({status: "success", data: result, message: 'Cập nhật thông tin chi nhánh thành công'}) 
    } catch (error) {
        res.status(error.status).send({status: "failed", message: error.message})
    }
})

router.get("/", async (req, res) => {
    try {
        const result = await branchService.getBranches()
        res.send({status: "success", data: result}) 
    } catch (error) {
        res.status(error.status).send({status: "failed", message: error.message})
    }
})



router.post("/", async (req, res) => {
    
})


router.delete("/", async (req, res) => {
    
})

module.exports = router

