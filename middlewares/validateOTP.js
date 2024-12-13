
const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET;

const authenticateBearerToken = (req, res, next) => {
    const authorizationHeader = req.headers.authorization;
    if (!authorizationHeader || !authorizationHeader.startsWith("Bearer ")) {
        return res.status(401).json({ status: "failed", message: "Authorization token missing or invalid" });
    }
    const token = authorizationHeader.split(" ")[1]; // Extract the token after "Bearer"
    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ status: "failed", message: "Token không hợp lệ hoặc đã hết hạn." });
        }
        console.log(user)
        req.user = user;
        next();
    });
};


module.exports = {
    authenticateBearerToken,
};

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
