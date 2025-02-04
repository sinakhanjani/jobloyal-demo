const controller = require("./payment.controller");

controller.getReportOfTransfers().then(res =>
    console.log(res)
);
