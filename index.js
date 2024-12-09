var express = require("express");
require("dotenv").config();
const app = express();
const roomRouter = require("./routes/rooms.route");
const amenityRouter = require("./routes/amenities.route");
const bookingRouter = require("./routes/booking.route");
const consumerGoodsRrouter = require("./routes/consumer_goods.route");
const empRouter = require("./routes/employees.route");
const branchRouter = require("./routes/branch.route");
const faciliTyRouter = require("./routes/CoSoVatChat.route");
const roomServiceRouter = require("./routes/room_service.route");
const discountRouter = require("./routes/discount.route");
var cors = require("cors");
const CORS_OPTION = {
    origin: ["http://localhost:3000"],
    credentials: true,
};
app.use(cors(CORS_OPTION));

app.use(express.urlencoded({ extended: true }));

app.use("/goods", consumerGoodsRrouter);
app.use("/rooms", roomRouter);
app.use("/amenities", amenityRouter);
app.use("/booking", bookingRouter);
app.use("/employees", empRouter);
app.use("/", faciliTyRouter);
app.use("/branches", branchRouter);
app.use("/room-service", roomServiceRouter);
app.use("/discounts", discountRouter);

app.listen(process.env.PORT, () => {
    console.log(`Server's listening at port ${process.env.PORT}`);
});
