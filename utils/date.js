const { addDays, compareAsc } = require("date-fns");

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

module.exports = getDateArray;
