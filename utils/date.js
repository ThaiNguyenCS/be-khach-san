const { addDays, compareAsc, format } = require("date-fns");

function getDateArray(startDate, endDate) {
    let start = new Date(startDate);
    let end = new Date(endDate);
    const arr = [];
    while (compareAsc(start, end) !== 1) {
        arr.push(start);
        start = addDays(start, 1);
    }
    return arr;
}

function formatDateTime(date) {
    if (date) {
        const fDate = new Date(date);
        return format(fDate, "yyyy-MM-dd HH:mm:ss");
    }
}

module.exports = {getDateArray, formatDateTime};
