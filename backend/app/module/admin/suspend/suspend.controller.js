const {SuspendUser} = require("../../../../database/models");

module.exports = {

    suspendUser: async function (req,res) {
        const {reason, user_id, expired, finite} = req.body;
        if (user_id) {
            const result = await SuspendUser.create({
                reason: reason,
                user_id: user_id,
                expired: expired || null,
                finite: finite || false,
                system: false
            });
            res.scaffold.add(result)
        }
    },

    deleteSuspend: async function (req, res) {
        const user_id = req.body.user_id;
        if (user_id) {
            const result = await SuspendUser.destroy({
                where: {
                    user_id: user_id
                }
            })
            res.scaffold.add(result)
        }
    }
};
