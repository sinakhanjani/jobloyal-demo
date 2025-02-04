const {sequelize,Service} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper");

//Other function on jobber/service/service.controller.js
module.exports = {

    edit: async function (req,res) {
        const {id,title,unit_id} = req.body;
        if (id && title) {
            const result = await Service.update({title,default_unit_id: unit_id}, {
                where: {id: id}
            });
            if (result.length > 0 && result[0] === 1) {
                res.scaffold.success()
            }
            else {
                res.scaffold.failed(messages.badUpdate)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    }

};
