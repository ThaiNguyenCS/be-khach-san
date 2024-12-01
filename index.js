var express = require("express");
require("dotenv").config();
const app = express();
const roomRouter = require("./routes/rooms.route");



app.use("/rooms", roomRouter);

app.listen(process.env.PORT, () => {
    console.log(`Server's listening at port ${process.env.PORT}`);
});

