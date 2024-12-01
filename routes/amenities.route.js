var express = require("express");
const { database } = require("../database");
const { generateUUIDV4 } = require("../utils/idManager");
const router = express.Router();

router.post("/", async (req, res) => {
    let {ten, moTa} = req.body
    try {
        // CALL (IN ID VARCHAR(50), IN Ten VARCHAR(255), IN MoTa TEXT)
        const QUERY = `CALL ThemTienNghiPhong ('${generateUUIDV4()}', '${ten}', '${moTa}')`
        
        const [result] = await database.query(QUERY)
        res.status(201).send({status: "success", message: "Thêm tiện nghi thành công"})
    } catch (error) {
        console.log(error.message);
        res.status(500).send({status: "failed", error: error.message})
    }
});



module.exports = router;
