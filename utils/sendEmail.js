const nodemailer = require("nodemailer");

const sendMail = async (email, subject, text) => {
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
        <title>fReset Password Email</title>
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
                Hotel Management - Lấy lại mật khẩu 
            </div>
            <div class="email-content">
                <p>Xin chào <strong>${email}</strong>,</p>
                <p>Chúng tôi đã nhận yêu cầu lấy lại mật khẩu cho tài khoản Hotel Management của bạn.</p>
              
                <div class="container">
            <div class="header">
              <h2>Mật khẩu mới của bạn là:</h2>
            </div>
            <div class="otp-box">
              ${text}
            </div>
          </div>
                <p class="safe-disclaimer">
                    Nếu bạn không gửi yêu cầu thì bạn có thể bỏ qua email này một cách an toàn. Có thể ai đó khác đã nhập địa chỉ email của bạn do nhầm lẫn.
                </p>
                <p>Xin cám ơn,</p>
                <p>Đội ngũ Hotel Management</p>
            </div>
            <div class="email-footer">  
                &copy; 2024 Hotel Management. All rights reserved.
            </div>
        </div>
    </body>
    </html>`;

    const mailOptions = {
        from: `"Hotel Management" <${process.env.APP_MAIL_ADDRESS}>`,
        to: email,
        subject: subject,
        html: mailHtml,
    };

    try {
        let info = await transporter.sendMail(mailOptions);
        console.log("Email sent: " + info.response);
    } catch (error) {
        console.error("Error sending email: ", error);
        throw error;
    }
};

module.exports = sendMail;
