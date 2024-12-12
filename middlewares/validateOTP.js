const sendMail  = require('../utils/sendEmail'); 

const generateOtp = () => Math.floor(100000 + Math.random() * 900000);
const requestOtp = async (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).send({ status: "failed", message: "Email không tồn tại" });
    }

    const otp = generateOtp();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 phút

    try {
        await database.query(
            `INSERT INTO otp_requests (email, otp_code, expires_at) VALUES (?, ?, ?)`,
            [email, otp, expiresAt]
        );

        await sendMail(email, otp);

        res.status(200).send({ status: "success", message: "OTP sent successfully" });
    } catch (error) {
        res.status(500).send({ status: "failed", message: error.message });
    }
}

const verifyOtp = async (req, res) => {
    const { email, otp } = req.body;

    if (!email || !otp) {
        return res.status(400).send({ status: "failed", message: "Email và OTP không được để trống" });
    }

    try {
        // Lấy OTP từ database
        const [otpRecord] = await database.query(
            `SELECT * FROM otp_requests WHERE email = ?`,
            [email]
        );

        if (!otpRecord.length) {
            return res.status(404).send({ status: "failed", message: "OTP không tồn tại hoặc đã hết hạn" });
        }

        const { otp_code, expires_at } = otpRecord[0];

        if (new Date() > new Date(expires_at)) {
            return res.status(400).send({ status: "failed", message: "OTP đã hết hạn" });
        }

        // Kiểm tra OTP
        if (otp_code !== otp) {
            return res.status(400).send({ status: "failed", message: "OTP không chính xác" });
        }
        //TODO
        

        // Xác thực thành công, xóa OTP
        await database.query(
            `DELETE FROM otp_requests WHERE email = ?`,
            [email]
        );

        res.status(200).send({ status: "success", message: "OTP xác thực thành công" });
    } catch (error) {
        res.status(500).send({ status: "failed", message: error.message });
    }
};

module.exports = {
    requestOtp,
    verifyOtp
}


/**

CREATE TABLE IF NOT EXISTS otp_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (email) -- Đảm bảo mỗi email chỉ có một bản ghi
);

 */
