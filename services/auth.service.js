const createHttpError = require("http-errors");
const { database } = require("../database");
const nodemailer = require("nodemailer");
const { checkMissingField, checkEmail } = require("../utils/errorHandler");
const { generateUUIDV4 } = require("../utils/idManager");
const { format, compareAsc } = require("date-fns");
require("dotenv").config();
const generateOtp = () => Math.floor(100000 + Math.random() * 900000);
const OTP_TTL = 10;
const jwt = require("jsonwebtoken");

const generateToken = (user) => {
    if (user) {
        const token = jwt.sign(
            {
                phoneNumber: user.SoDienThoai,
                email: user.Email,
            },
            process.env.JWT_SECRET,
            { expiresIn: "1d" }
        );
        return token;
    } else {
        return "";
    }
};

class AuthService {
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    verifyOtp = async (data) => {
        const { phoneNumber, otp } = data;

        if (!phoneNumber || !otp) {
            throw createHttpError(403, "Số điện thoại và OTP không được để trống");
        }
        const connection = await database.getConnection();
        await connection.beginTransaction();
        try {
            // Lấy OTP từ database
            const [otpRecord] = await database.query(`SELECT * FROM OTP WHERE SoDienThoai = '${phoneNumber}'`);
            console.log(otpRecord);

            if (!otpRecord.length) {
                throw createHttpError(403, "OTP không tồn tại hoặc đã hết hạn");
            }

            const { HetHan, OTP } = otpRecord[0];
            console.log("HETHAN", HetHan);

            if (compareAsc(new Date(Date.now()), new Date(HetHan)) === 1) {
                throw createHttpError(403, "OTP đã hết hạn");
            }

            // Kiểm tra OTP
            if (otp !== OTP) {
                throw createHttpError(401, "OTP không chính xác");
            }

            // Xác thực thành công, xóa OTP
            await connection.query(`DELETE FROM OTP WHERE SoDienThoai = ?`, [phoneNumber]);
            const [user] = await connection.query(
                `SELECT * FROM KhachHang WHERE SoDienThoai = '${phoneNumber}' LIMIT 1`
            );

            const token = generateToken(user[0]);

            if (!token) {
                throw createHttpError(500, "Lỗi tạo token");
            }
            await connection.commit();
            return { token };
        } catch (error) {
            await connection.rollback();
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        } finally {
            connection.release();
        }
    };

    sendMail = async (email, subject, text) => {
        const transporter = nodemailer.createTransport({
            host: "smtp.gmail.com",
            port: 587,
            secure: false,
            auth: {
                user: process.env.APP_MAIL_ADDRESS || "nh0kcrazy04@gmail.com",
                pass: process.env.APP_MAIL_PASSWORD,
            },
        });

        const mailHtml = `
    <html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #f4f4f4;
                margin: 0;
                padding: 0;
            }
            .email-container {
                max-width: 600px;
                margin: 20px auto;
                background-color: #ffffff;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
            .email-header {
                text-align: center;
                font-size: 24px;
                font-weight: bold;
                color: #333333;
                margin-bottom: 20px;
            }
            .email-content {
                font-size: 16px;
                color: #555555;
                line-height: 1.6;
            }
            .otp {
                font-size: 20px;
                font-weight: bold;
                color: #d9534f;
                text-align: center;
                margin: 20px 0;
            }
            .email-footer {
                font-size: 14px;
                color: #999999;
                text-align: center;
                margin-top: 30px;
            }
            .safe-disclaimer {
                color: #777777;
            }
            .container {
              max-width: 600px;
              margin: 20px auto;
              background-color: #fff;
              border-radius: 10px;
              padding: 20px;
              box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            }
            .header {
              text-align: center;
              color: #333;
              font-size: 24px;
              margin-bottom: 20px;
            }
            .otp-box {
              font-size: 32px;
              font-weight: bold;
              letter-spacing: 5px;
              background-color: #f3f4f6;
              padding: 10px;
              border-radius: 5px;
              text-align: center;
              color: #333;
              box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
              margin: 20px 0 10px;
            }
        </style>
    </head>
    <body>
        <div class="email-container">
            <div class="email-header">
                Best Hotel Ever
            </div>
            <div class="email-content">
                <p>Xin chào <strong>${email}</strong>,</p>
                <p>Đây là OTP để đăng nhập vào tài khoản Best Hotel Ever của bạn. Mã OTP có thời hạn trong vòng ${OTP_TTL} phút</p>
              
                <div class="container">
            <div class="otp-box">
              ${text}
            </div>
          </div>
                <p class="safe-disclaimer">
                    Nếu bạn không gửi yêu cầu thì bạn có thể bỏ qua email này một cách an toàn. Có thể ai đó khác đã nhập địa chỉ email của bạn do nhầm lẫn.
                </p>
                <p>Xin cám ơn,</p>
                <p>Đội ngũ Best Hotel Ever</p>
            </div>
            <div class="email-footer">  
                &copy; 2024 Best Hotel Ever. All rights reserved.
            </div>
        </div>
    </body>
    </html>`;

        const mailOptions = {
            from: `"Admin Best Hotel Ever" <${process.env.APP_MAIL_ADDRESS}>`,
            to: email,
            subject: subject,
            html: mailHtml,
        };

        try {
            let info = await transporter.sendMail(mailOptions);
            console.log("Email sent: " + info.response);
            return { email: email };
        } catch (error) {
            console.error("Error sending email: ", error);
            throw error;
        }
    };

    async sendOTP(data) {
        console.log(data);

        let { email, phoneNumber, type = "exclusive" } = data;
        // if user enter new email then store it in the DB
        if (type === "inclusive" && !email) {
            if (!email) throw createHttpError(400, "Vui lòng điền email!");
            if (!this.isValidEmail(email)) {
                throw createHttpError(400, "Email không hợp lệ!");
            }
        }

        const connection = await database.getConnection();

        try {
            checkMissingField("phoneNumber", phoneNumber);
            const QUERY = `SELECT * FROM KhachHang WHERE SoDienThoai = '${phoneNumber}' LIMIT 1`;
            // Find the customer in the DB
            const [user] = await database.query(QUERY);
            // If user exists
            await connection.beginTransaction();
            if (user.length > 0) {
                let sendingEmail = "";
                const otp = generateOtp();

                if (type === "inclusive") {
                    sendingEmail = email;
                    const UPDATE_EMAIL_QUERY = `UPDATE KhachHang SET Email = '${email}' WHERE SoDienThoai = '${phoneNumber}'`;
                    await connection.query(UPDATE_EMAIL_QUERY);
                } else if (user[0].Email) {
                    sendingEmail = user[0].Email;
                } else {
                    throw createHttpError(
                        404,
                        `Không tìm thấy email của khách hàng sdt ${phoneNumber}. Vui lòng cập nhật email`
                    );
                }
                // Delete the old one of a phone number
                await connection.query(`DELETE FROM OTP WHERE SoDienThoai = ?`, [user[0].SoDienThoai]);
                const createdAt = format(new Date(Date.now()), "yyyy-MM-dd HH:mm:ss");
                const expireAt = format(new Date(Date.now() + OTP_TTL * 60 * 1000), "yyyy-MM-dd HH:mm:ss");
                await connection.query(
                    `INSERT INTO OTP (ID, OTP, SoDienThoai, HetHan, ThoiGianTao) VALUES (?, ?, ?, ?, ?)`,
                    [generateUUIDV4(), otp, user[0].SoDienThoai, expireAt, createdAt]
                );
                await this.sendMail(sendingEmail, "Đăng nhập ứng dụng", otp);
                await connection.commit();
                // res.status(200).send({ status: "success", message: "OTP sent successfully" });
                return { message: `Mã OTP đã được gửi đến địa chỉ ${sendingEmail}` };
            } else {
                throw createHttpError(404, `Không tồn tại khách hàng với số điện thoại ${phoneNumber}`);
            }
        } catch (error) {
            console.error("Error:", error);
            await connection.rollback();
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        } finally {
            connection.release();
        }
    }

    async register(data) {
        let { cusName, cusPhoneNumber, cusCitizenId, cusSex, cusDOB, cusEmail } = data;
        try {
            checkMissingField("cusName", cusName);
            checkMissingField("cusPhoneNumber", cusPhoneNumber);
            checkMissingField("cusCitizenId", cusCitizenId);
            checkMissingField("cusSex", cusSex);
            checkMissingField("cusDOB", cusDOB);
            checkMissingField("cusEmail", cusEmail);
            if (!checkEmail(cusEmail)) throw createHttpError(400, "Định dạng email không hợp lệ");
            const QUERY = `INSERT INTO KhachHang (ID, Ten, CCCD, SoDienThoai, NgaySinh, GioiTinh, Email) VALUES 
            ('${generateUUIDV4()}', '${cusName}', '${cusCitizenId}', '${cusPhoneNumber}', '${format(
                new Date(cusDOB),
                "yyyy-MM-dd"
            )}', '${cusSex}',  '${cusEmail}')`;
            console.log(QUERY);

            const [result] = await database.query(QUERY);
            return {};
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async getProfile(user) {
        try {
            const QUERY = `SELECT * FROM KhachHang WHERE SoDienThoai = '${user.phoneNumber}'`;
            const [userInfo] = await database.query(QUERY);
            return userInfo[0];
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }

    async updateProfile(data) {
        let { user, cusName, cusCitizenId, cusSex, cusDOB, cusEmail } = data;
        console.log("data updateProfile", data);

        try {
            checkMissingField("user", user);
            const updates = [];
            if (cusName) {
                updates.push(`Ten = '${cusName}'`);
            }
            if (cusCitizenId) {
                updates.push(`CCCD = '${cusCitizenId}'`);
            }
            if (cusSex) {
                updates.push(`GioiTinh = '${cusSex}'`);
            }
            if (cusDOB) {
                updates.push(`NgaySinh = '${format(new Date(cusDOB), "yyyy-MM-dd")}'`);
            }
            if (cusEmail) {
                updates.push(`Email = '${cusEmail}'`);
            }
            if (updates.length > 0) {
                const UPDATE_QUERY = `UPDATE KhachHang SET ${updates.join(", ")} WHERE SoDienThoai = '${
                    user.phoneNumber
                }'`;
                const [result] = await database.query(UPDATE_QUERY);
            } else throw createHttpError(400, "Vui lòng nhập ít nhất 1 trường cần cập nhật");
        } catch (error) {
            if (error.status) throw error;
            throw createHttpError(500, error.message);
        }
    }
}

module.exports = new AuthService();
