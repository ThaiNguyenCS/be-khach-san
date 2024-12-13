const createHttpError = require("http-errors");

function checkMissingField(fieldName, value) {
    if (!value) {
        throw createHttpError(400, `${fieldName} is missing`);
    }
}

function checkEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

module.exports = { checkMissingField, checkEmail };
