const {Payment,Deposit,User,Request,sequelize} = require("../../../../database/models");

function isUUID ( uuid ) {
    let s = "" + uuid;
    s = s.match('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (s === null) {
        return false;
    }
    return true;
}

module.exports = {

    getAllPayments: async (req,res) => {
        const {page, limit} = req.body;
        let count = null;
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."Payments"', {
                nest: true
            });
            count = parseInt(count[0].count)
        }
        const payments = await sequelize.query('SELECT pay.id, concat(u.name, \' \', u.family) as name, pay.total_amount, pay.payable_amount, job.title ->> \'en\' as title,pay.request_id, pay.user_id, pay.status, pay.created_at FROM public."Payments" as pay LEFT OUTER JOIN public."Users" as u on u.id = pay.user_id Left Outer Join public."Requests" as req on req.id = pay.request_id Left Outer Join public."Jobs" as job on job.id = req.job_id order by pay.created_at limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({count, items: payments})
    },

    searchPayments: async (req,res) => {
        const {page, limit,s} = req.body;
        let count = null;
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."Payments" where user_id = :s or request_id = :s', {
                nest: true,
                replacements: {
                    s: `${s}`
                }
            });
            count = parseInt(count[0].count)
        }
        const payments = await sequelize.query('SELECT pay.id, concat(u.name, \' \', u.family) as name, pay.total_amount, pay.payable_amount, job.title ->> \'en\' as title,pay.request_id, pay.user_id, pay.status, pay.created_at FROM public."Payments" as pay LEFT OUTER JOIN public."Users" as u on u.id = pay.user_id Left Outer Join public."Requests" as req on req.id = pay.request_id Left Outer Join public."Jobs" as job on job.id = req.job_id where pay.user_id = :s or pay.request_id = :s order by pay.created_at limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    s: `${s}`,
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({count, items: payments})
    },

    getAllDeposits: async (req,res) => {
        const {page, limit} = req.body;
        let count = null;
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."Deposits"', {
                nest: true
            });
            count = parseInt(count[0].count)
        }
        const payments = await sequelize.query('SELECT pay.id, concat(u.name, \' \', u.family) as name,pay.ref_code, pay.amount, pay.jobber_id, pay.status, pay.created_at FROM public."Deposits" as pay LEFT OUTER JOIN public."Jobbers" as u on u.id = pay.jobber_id order by pay.created_at limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({count, items: payments})
    },

    searchDeposits: async (req,res) => {
        const {page, limit,s} = req.body;
        let count = null;
        let whereCondition = '';
        if (isUUID(s)) {
            whereCondition = ' where jobber_id = :s or id = :s or ref_code = :s';
        }
        else {
            whereCondition = ' where ref_code = :s';
        }
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."Deposits"' + whereCondition, {
                nest: true,
                replacements: {
                    s: `${s}`
                }
            });
            count = parseInt(count[0].count)
        }
        const payments = await sequelize.query('SELECT pay.id, concat(u.name, \' \', u.family) as name,pay.ref_code, pay.amount, pay.jobber_id, pay.status, pay.created_at FROM public."Deposits" as pay LEFT OUTER JOIN public."Jobbers" as u on u.id = pay.jobber_id' + whereCondition + ' order by pay.created_at limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    s: `${s}`,
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({count, items: payments})
    },


    getAllFailedDeposit: async (req,res) => {
        const {page, limit} = req.body;
        let count = null;
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."FailedDeposits"', {
                nest: true
            });
            count = parseInt(count[0].count)
        }
        const payments = await sequelize.query('SELECT deposit_id,ref_code,message,created_at FROM public."FailedDeposits" order by created_at desc limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({count, items: payments})
    },

    searchFailedDeposit: async (req,res) => {
        const {page, limit,s} = req.body;
        let count = null;
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."FailedDeposits"  where deposit_id = :s or ref_code = :s', {
                nest: true,
                replacements: {
                    s: `${s}`
                }
            });
            count = parseInt(count[0].count)
        }
        const payments = await sequelize.query('SELECT deposit_id,ref_code,message,created_at FROM public."FailedDeposits" where deposit_id = :s or ref_code = :s order by created_at desc limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    s: `${s}`,
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({count, items: payments})
    }

};
