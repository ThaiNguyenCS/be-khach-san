// const newman = require('newman');
// const async = require('async');

// const PARALLEL_RUNS = 100;

// async.times(PARALLEL_RUNS, function (n, next) {
//     newman.run({
//         collection: require('./collection.json'), // Path to your exported collection
//         reporters: 'cli'
//     }, next);
// }, function (err) {
//     if (err) {
//         console.error(err);
//     } else {
//         console.log(`${PARALLEL_RUNS} parallel requests completed.`);
//     }
// });

// function isValidEmail(email) {
//     const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
//     return emailRegex.test(email);
// }

// console.log(isValidEmail("thainguyen@gmail.com"));
// console.log(isValidEmail("thainguyen@hcmut.edu.vn"));
// console.log(isValidEmail("thainguyen@@gmail.com"));
// console.log(isValidEmail("thainguyen@gmail.com.vb.cb"));
// console.log(isValidEmail("thainguyen@gmail.com"));

const csv = require("csv-parser");
const fs = require("fs");

const numberIdxes = {  };

function generateInsertSQL(csvFilePath, tableName) {
    let sql = `INSERT INTO ${tableName} (`;
    let columns = [];
    let values = [];

    fs.createReadStream(csvFilePath)
        .pipe(csv())
        .on("data", (row) => {
            console.log(row);

            const rowValues = Object.values(row).map((value, idx) => {
                if (value === "NULL") return `NULL`;
                if (numberIdxes.idx) {
                    if (numberIdxes.idx === "float") {
                        return `${parseFloat(value)}`;
                    } else {
                        return `${parseInt(value)}`;
                    }
                }
                return `'${value}'`;
            });
            values.push(`(${rowValues.join(", ")})`);

            if (!columns.length) {
                columns = Object.keys(row);
                sql += columns.join(", ") + ") VALUES ";
            }
        })
        .on("end", () => {
            sql += values.join(", ");
            sql += ";"
            fs.writeFileSync("insert_sql.txt", sql);
            console.log("SQL statements generated successfully!");
        });
}

// Example usage:
// let csvFilePath = "C://Users//THAI//OneDrive//Desktop//Database - Phòng.csv";
let csvFilePath = "C://Users//THAI//OneDrive//Desktop//khachhang.csv";
// let csvFilePath = "C://Users//THAI//OneDrive//Desktop//Database - Phòng.csv";
// let csvFilePath = "C://Users//THAI//OneDrive//Desktop//Database - Phòng.csv";

console.log(csvFilePath);

const tableName = "KhachHang";

generateInsertSQL(csvFilePath, tableName);
