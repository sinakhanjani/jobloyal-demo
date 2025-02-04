const {User,sequelize} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper");
const {amountOfWallet} = require("../../user/wallet/wallet.controller");

function fillArray(value, len) {
    if (len == 0) return [];
    var a = [value];
    while (a.length * 2 <= len) a = a.concat(a);
    if (a.length < len) a = a.concat(a.slice(0, len - a.length));
    return a;
}
module.exports = {

    getAll: async function (req,res) {
        const {page, limit} = req.body;
        let userCount = null;
        if (page === 0) {
            userCount = await sequelize.query('SELECT COUNT(*) from public."Users" where deleted_at is null ', {
                nest: true
            });
            userCount = parseInt(userCount[0].count)
        }
        const users = await sequelize.query('select "user".*,su.finite,su.expired from public."Users" as "user" left outer join public."SuspendUsers" as su on su.user_id = "user".id where deleted_at is null  order by "user".created_at DESC limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({"count" : userCount, items: users})
    },

    searchUser: async function (req,res) {
        const {page, limit,s} = req.body;
        let search = s.replace(" ","%");
        let userCount = null;
        if (page === 0) {
            userCount = await sequelize.query('SELECT COUNT(*) from public."Users" as "user" left outer join public."SuspendUsers" as su on su.user_id = "user".id where "user".name like :s or "user".family ilike :s or "user".phone_number like :s or concat("user".name,"user".family) ilike :s ', {
                nest: true,
                replacements: {
                    s: `%${search}%`
                }
            });
            userCount = parseInt(userCount[0].count)
        }
        const users = await sequelize.query('select "user".*,su.finite,su.expired from public."Users" as "user" left outer join public."SuspendUsers" as su on su.user_id = "user".id where "user".name ilike :s or "user".family ilike :s or "user".phone_number ilike :s or concat("user".name,"user".family) ilike :s order by "user".created_at DESC limit :limit offset :page ',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10,
                    s: `%${search}%`
                }
            });
        res.scaffold.add({"count" : userCount, items: users})
    },

    getUserByUserId : async function (req,res) {
        const user_id = req.params.id;
        const user = await sequelize.query('select u.*, request.id as "last_request_id",suspend_user.reason as "suspend.reason",suspend_user.finite as "suspend.finite",suspend_user.expired as "suspend.expired", request_done_count.count::INT as done_request , count_request.count::INT as total_request,request_canceled_count.count::INT  as total_canceled_request, total_pay.total as "total_payment" from public."Users" as u left outer join (select id from public."Requests" as request where request.user_id = :id order by request.created_at desc limit 1) as request on 1 = 1 left outer join (select COUNT(*) from public."Requests" as req where req.user_id = :id) as count_request on 1 = 1 left outer join (select COUNT(*) from public."Requests" as req where req.user_id = :id and (req.status = \'verified\' or req.status = \'done\' or req.status = \'deposited\')) as request_done_count on 1 = 1 left outer join (select COUNT(*) from public."Requests" as req where req.user_id = :id and (req.status = \'canceled-by-user\')) as request_canceled_count on 1 = 1 left outer join (select sum(payment.payable_amount) as total from public."Requests" as req left outer join public."Payments" payment on payment.request_id = req.id where payment.status = \'success\' and req.user_id = :id and (req.status = \'verified\' or req.status = \'done\' or req.status = \'deposited\')) as total_pay on 1 = 1 left outer join (select reason,finite,expired from public."SuspendUsers" as su where su.user_id = :id and ((su.finite = true and su.expired > NOW()) or (su.finite = false)) limit 1) as suspend_user on 1 = 1 where u.id = :id', {
            nest: true,
            replacements: {
                id: user_id
            }
        });
        if (user.length > 0 && user[0].hasOwnProperty("id")) {
            const userResponse = {...user[0]};
            const wallet = await amountOfWallet(user_id);
            if (userResponse.suspend.finite === null) userResponse.suspend = null;

            userResponse.tags  = [
                {
                    "title": "Total Request",
                    "value": userResponse.total_request
                },
                {
                    "title": "Done Request",
                    "value": userResponse.done_request
                },
                {
                    "title": "Total Canceled Request",
                    "value": userResponse.total_canceled_request
                },
                {
                    "title": "Wallet",
                    "value": wallet + " CHF"
                },
                {
                    primary: true,
                    title: "Total Payment",
                    value: userResponse.total_payment,
                    subvalue: "CHF"
                }
            ];
            res.scaffold.add(userResponse)
         }
        else {
            res.scaffold.failed(messages.noUserFound)
        }
    }
};
