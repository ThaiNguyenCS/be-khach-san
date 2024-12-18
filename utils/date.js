const {
    addDays,
    compareAsc,
    format,
    isEqual,
    isBefore,
    addYears,
    startOfMonth,
    startOfYear,
    addMonths,
} = require("date-fns");

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

function getDateArrayV2(startDate, endDate, option) {
    if (option === "date") {
        return getDateArray(startDate, endDate);
    }
    if (option === "month") {
        let start = startOfMonth(new Date(startDate));
        let end = startOfMonth(new Date(endDate));
        console.log(start, end);
        
        const arr = [];
        while (isBefore(start, end) || isEqual(start, end)) {
            arr.push(format(start, "yyyy-MM"));
            start = addMonths(start, 1);
        }
        console.log(arr);

        return arr;
    }
    if (option === "year") {
        let start = startOfYear(new Date(startDate));
        let end = startOfYear(new Date(endDate));
        const arr = [];
        while (isBefore(start, end) || isEqual(start, end)) {
            arr.push(format(start, "yyyy"));
            start = addYears(start, 1);
        }
        return arr;
    }
}

function formatDateTime(date) {
    if (date) {
        const fDate = new Date(date);
        return format(fDate, "yyyy-MM-dd HH:mm:ss");
    }
}

module.exports = { getDateArray, formatDateTime, getDateArrayV2 };
