const controller = require("./payment.controller");

controller.deposit().then(
    console.log("Complete")
);
