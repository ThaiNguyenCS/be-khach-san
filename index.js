var express = require("express");
require("dotenv").config();
const app = express();
const roomRouter = require("./routes/rooms.route");
const amenityRouter = require("./routes/amenities.route");
const bookingRouter = require("./routes/booking.route");

app.use(express.urlencoded({ extended: true }));

app.use("/rooms", roomRouter);
app.use("/amenities", amenityRouter);
app.use("/booking", bookingRouter);

app.listen(process.env.PORT, () => {
    console.log(`Server's listening at port ${process.env.PORT}`);
});
