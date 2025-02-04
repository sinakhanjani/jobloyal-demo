const {DeviceInfo} = require("../../../../database/models");
const fa = require("firebase-admin");

module.exports = {

    sendNotification : async (req,res) => {
        const {user_id,title,content} = req.body;
        const tokensReq = await DeviceInfo.findAll({
            attributes: ['fcm'],
            where: {
                user_id: user_id,
            },
            raw: true
        });
        const tokens = tokensReq.flatMap ((e) => e.fcm || []);
        if (tokens.length > 0) {
            let message = {
                data: {method: 'DSP'},
                tokens: tokens,
                ttl: 0,
                apns: {payload: {aps: {sound: 'default'}}},
                priority: "high",
                mutableContent: true,
                contentAvailable: true,
                notification: {
                    title: title,
                    body: content
                }
            };

            fa.messaging().sendMulticast(message)
                .then((response) => {
                    if (response.failureCount > 0) {
                        const failedTokens = [];
                        response.responses.forEach((resp, idx) => {
                            if (!resp.success) {
                                failedTokens.push(idx);
                            }
                        });
                    }
                    res.scaffold.success()
                });
        }
        else {
            res.scaffold.success()
        }
    }
};
