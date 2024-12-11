const newman = require('newman');
const async = require('async');

const PARALLEL_RUNS = 100;

async.times(PARALLEL_RUNS, function (n, next) {
    newman.run({
        collection: require('./collection.json'), // Path to your exported collection
        reporters: 'cli'
    }, next);
}, function (err) {
    if (err) {
        console.error(err);
    } else {
        console.log(`${PARALLEL_RUNS} parallel requests completed.`);
    }
});
