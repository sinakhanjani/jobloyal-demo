const {Message,ReplyMessage} = require('../../../../database/models')
const messages = require('../../../../helper/message.helper')

module.exports = {

    create: async function (req,res) {
        const user_id = req.user.id;
        const {subject,description} = req.body;
        if (subject && description) {
            try {
                const message = await Message.create({
                    user_id: user_id,
                    subject: subject,
                    description: description
                });
                res.scaffold.success()
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    get: async function (req,res) {
        const user_id = req.user.id;
        const allMessages = await Message.findAll({
            where: {user_id: user_id},
            include: {model: ReplyMessage, as: 'reply'}
        });
        res.scaffold.add({items: allMessages})
    }
};
