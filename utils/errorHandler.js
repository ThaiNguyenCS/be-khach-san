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

function checkMonthValue(month) {
    if (month < 1 || month > 12) throw createHttpError(400, `${month} is not a valid month`);
}
module.exports = { checkMissingField, checkEmail, checkMonthValue };
