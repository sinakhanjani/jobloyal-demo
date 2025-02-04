const {SuspendUser} = require("../../../../database/models");

module.exports = {

  getDetail: async function (req,res) {
      const user_id = req.user.id;
      const suspend = await SuspendUser.findOne({
          where: {
              user_id: user_id
          }
      });
      if (suspend != null) {
          if (suspend && suspend.finite === false || (suspend.finite === true && (suspend.expired != null && suspend.expired >= new Date()))) {
              res.scaffold.add(suspend)
          } else {
              res.scaffold.success()
          }
      }
      else {
          res.scaffold.success()
      }
  }
};
