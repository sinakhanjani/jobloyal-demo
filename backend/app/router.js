const common = require("./module/common/common.router");
const jobber = require("./module/jobber/jobber.router");
const admin = require("./module/admin/admin.router");
const user = require("./module/user/user.router");

module.exports =  function (app) {
   app.all("/v1/admin/*", (req, res, next) => {
      let origin = req.headers.origin;
      // if (origin === "https://panel.jobloyal.com") {
         res.header("Access-Control-Allow-Origin", origin);
      // }
      res.header("Access-Control-Allow-Headers", ["Content-Type","X-Requested-With","Authorization","X-HTTP-Method-Override","Accept"]);
      res.header("Access-Control-Allow-Credentials", true);
      res.header("Access-Control-Allow-Methods", "GET,POST");
      res.header("Cache-Control", "no-store,no-cache,must-revalidate");
      res.header("Vary", "Origin");
      next();
   });
   app.use("/v1/common",common);
   app.use("/v1/jobber",jobber);
   app.use("/v1/admin",admin);
   app.use("/v1/user",user);



};
