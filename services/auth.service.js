const createHttpError = require("http-errors");
const { database } = require("../database");

class AuthService {
    async sendOTP (data)  {
        let {email, phoneNumber} = data

        if (!email) {
            throw createHttpError(400, "Vui lòng điền email!")
        }
    
        try {
            const QUERY = `SELECT * FROM KhachHang WHERE SoDienThoai = '${phoneNumber}' LIMIT 1`

            const [user] = await database.query(QUERY)
            if(user.length > 0)
            {

            }
            throw createHttpError(404, `Không tồn tại khách hàng với số điện thoại ${phoneNumber}`)
            if (!user) {
                res.status(400).json({
                    status: "failed",
                    message: "Email không tồn tại.",
                });
                return;
            }
            let dummyPassword = generateRandomPassword(); // generate a dummy password
            let hashedPassword = await getHashedPassword(dummyPassword);
            await user.update({ password: hashedPassword }); // update that new password to database
    
            const subject = "Khôi phục mật khẩu";
            const text = `${dummyPassword}`;
            await sendMail(req.body.email, subject, text);
    
            res.json({
                status: "success",
                message: "Đã gửi mật khẩu thành công",
            });
        } catch (error) {
            console.error("Error:", error);
            res.status(500).json({
                status: "failed",
                message: "Có lỗi xảy ra, vui lòng thử lại sau.",
            });
        }
    };
}


module.exports = new AuthService()