const createHttpError = require("http-errors");

function checkMissingField(fieldName, value) {
    if (!value) {
        throw createHttpError(400, `${fieldName} is missing`);
    }
}


module.exports = {checkMissingField}