const {DeviceInfo,sequelize} = require("../../../../database/models")
const messages = require("../../../../helper/message.helper")
const Sequelize = require('sequelize');
const Op = Sequelize.Op;

module.exports = {

    addDeviceInfo: async function (req, res) {
        const user_id = req.user.id;
        const user_device_id = req.user.device;
        const {device_id, device_type, extra, fcm} = req.body;
        if (device_id && device_type && fcm) {
            await DeviceInfo.destroy({
                where: {
                    user_id: user_id,
                    device_id: device_id,
                    id: {[Op.ne]: user_device_id}
                }
            });
            await DeviceInfo.update({
                device_type: device_type,
                fcm: fcm,
                extra: extra,
                device_id: device_id
            }, {
                where: {
                    id: user_device_id,
                    user_id: user_id
                }
            });
            res.scaffold.success()
        } else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    logout: async function (req, res) {
        const userId = req.user.id;
        const region = req.user.region;
        const request = await sequelize.query('SELECT "Request"."id" FROM "Requests" AS "Request" WHERE "Request"."user_id" = :user_id AND (("Request"."status" = \'finished\' OR ("Request"."status" = \'created\' AND "Request"."created_at" > NOW() - INTERVAL :req_time_life)) OR "Request"."status" = \'paid\'  OR "Request"."status" = \'accepted\' OR "Request"."status" = \'arrived\' OR "Request"."status" = \'started\') ORDER BY "Request"."created_at" DESC LIMIT 1', {
            replacements: {
                user_id: userId,
                region: region,
                req_time_life: `${process.env.REQUEST_LIFE_TIME} minutes`
            },
            nest: true,
        });
        if (request.length > 0) {
            res.scaffold.failed(messages.userHaveLiveRequest)
        } else {
            try {
                const result = await DeviceInfo.destroy({
                    where: {
                        id: req.user.device
                    }
                });

                if (result >= 1) {
                    res.scaffold.success()
                } else {
                    res.scaffold.failed(messages.unknown)
                }
            } catch (e) {
                res.scaffold.failed(e.message)
            }
        }
    }
};
