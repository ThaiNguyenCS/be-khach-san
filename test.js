const { isBefore, isEqual, addMonths, format, startOfMonth, addYears, startOfYear } = require("date-fns");

function getDateArrayV2(startDate, endDate, option) {
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

const result = addMonths(new Date('2024-11-30T17:00:00.000Z'), 1)
console.log(result);


