const {ReplyMessage,Message,sequelize} = require('../../../../database/models')

module.exports = {
    sendReply: async function (req,res) {
        const {answer,message_id} = req.body;
        if (answer && message_id) {
            const reply = await ReplyMessage.create({
                message_id: message_id,
                answer: answer
            });
            res.scaffold.add({item: reply})
        }
    },

    getAllMessage: async function (req,res) {
        const {page, limit} = req.body;
        try {
            let count = 0;
            if (page === 0) {
                count = await Message.count()
            }
            const messages = await sequelize.query('SELECT "Message"."id", "Message"."subject", "Message"."description", "Message"."created_at" AS "createdAt", "Message"."updated_at" AS "updatedAt", "reply"."id" AS "reply.id", "reply"."message_id" AS "reply.message_id", "reply"."answer" AS "reply.answer", "reply"."created_at" AS "reply.createdAt", "reply"."updated_at" AS "reply.updatedAt","Message"."user_id" as "user.id", COALESCE (jobber.name,users.name) as "user.name", COALESCE (jobber.family,users.family) as "user.family", COALESCE (jobber.created_at > date \'2012-01-01\',\'false\') as "user.is_jobber",COALESCE (jobber.region,users.region) as "user.region", jobber.identifier as "user.jobber_id" FROM "Messages" AS "Message" LEFT OUTER JOIN "ReplyMessages" AS "reply" ON "Message"."id" = "reply"."message_id" LEFT OUTER JOIN public."Jobbers" as jobber  ON jobber.id = "Message"."user_id" LEFT OUTER JOIN public."Users" as users ON users.id = "Message"."user_id" order by "Message".created_at desc limit :limit offset :page ',
                {
                    replacements: {
                        page: (page || 0) * (limit || 10),
                        limit: limit || 10
                    },
                    nest: true
                });
            messages.forEach(e => {
                if (e.reply.id === null) {
                    e.reply = null
                }
            });
            res.scaffold.add({count,items: messages})
        }
        catch (e) {
            res.scaffold.failed(e.message)
        }
    },

    getMessage: async function (req, res) {
        const {id} = req.body;
        const messages = await sequelize.query('SELECT "Message"."id", "Message"."subject", "Message"."description", "Message"."created_at" AS "createdAt", "Message"."updated_at" AS "updatedAt", "reply"."id" AS "reply.id", "reply"."message_id" AS "reply.message_id", "reply"."answer" AS "reply.answer", "reply"."created_at" AS "reply.createdAt", "reply"."updated_at" AS "reply.updatedAt","Message"."user_id" as "user.id", COALESCE (jobber.name,users.name) as "user.name", COALESCE (jobber.family,users.family) as "user.family", COALESCE (jobber.created_at > date \'2012-01-01\',\'false\') as "user.is_jobber",COALESCE (jobber.region,users.region) as "user.region", jobber.identifier as "user.jobber_id" FROM "Messages" AS "Message" LEFT OUTER JOIN "ReplyMessages" AS "reply" ON "Message"."id" = "reply"."message_id" LEFT OUTER JOIN public."Jobbers" as jobber  ON jobber.id = "Message"."user_id" LEFT OUTER JOIN public."Users" as users ON users.id = "Message"."user_id" where "Message".id = :id',
            {
                replacements: {id},
                nest: true
            });
        messages.forEach(e => {
            if (e.reply.id === null) {
                e.reply = null
            }
        });
        res.scaffold.add(messages[0])
    }
};
