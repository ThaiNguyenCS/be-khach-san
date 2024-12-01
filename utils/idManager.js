var { v4 } = require("uuid");
const generateUUIDV4 = () => {
    return v4();
};

module.exports = { generateUUIDV4 };
