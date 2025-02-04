const {Request,sequelize,Comment} = require("../../../../database/models");

function isUUID ( uuid ) {
    let s = "" + uuid;
    s = s.match('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (s === null) {
        return false;
    }
    return true;
}
function validEnum (en) {
    return en === 'created' || en === 'accepted' || en === 'canceled-by-user' || en === 'canceled-by-jobber' || en === 'no-answer-busy' || en === 'no-answer-free' || en === 'arrived' || en === 'started' || en === 'finished' || en === 'verified' || en === 'paid' || en === 'done' || en === 'rejected' || en === 'deposited' || en === "ok";
}

module.exports = {

    getRequestByID : async function (req,res) {
        const {id} = req.body;
        try {
            const request = await sequelize.query('select request.*,longitude(location),latitude(location),row_to_json("user".*) as "user", row_to_json(jobber) as jobber, row_to_json(job) as job ,json_agg(rsr) as report from public."Requests" as request  left outer join public."Users" as "user" on "user".id = request.user_id left outer join public."Jobbers" as jobber on jobber.id = request.jobber_id left outer join public."Jobs" as job on job.id = request.job_id left outer join public."RequestStatusReport" as rsr on rsr.request_id = request.id where request.id = :id group by request.id,"user".id,jobber.id,job.*', {
                replacements: {
                    id: id
                },
                nest: true,
                raw: true
            });
            const services = await sequelize.query('select rs.*, js.title,js.unit_title from public."RequestServices" as rs left outer join (select js.id,unit.title as unit_title, serv.title as title from public."JobberServices" as js left outer join public."Services" as serv on js.service_id = serv.id left outer join public."Units" as unit on unit.id = js.unit_id where js.deleted_at is null) as js on js.id = rs.service_id where request_id = :id', {
                replacements: {
                    id: id
                },
                nest: true
            });
            const comment = await Comment.findOne({
                where: {
                    request_id: id
                }
            });
            res.scaffold.add({...request[0], services,comment})
        }
        catch (e) {
            res.scaffold.failed(e.message)
        }
    },

    getAll : async function (req,res) {
        const {page, limit} = req.body;
        let count = null;
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."Requests"', {
                nest: true
            });
            count = parseInt(count[0].count)
        }
        const result = await sequelize.query('select req.*,jobber.name as jobber_name, u.name as user_name, job.title as job_title from public."Requests" as req left outer join (select concat(name,\' \',family) as name,id from public."Jobbers") as jobber on jobber.id = req.jobber_id left outer join (select concat(name,\' \',family) as name,id from public."Users") as u on u.id = req.user_id left outer join (select title,id from public."Jobs") as job on job.id = req.job_id limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({"count" : count, items: result})
    },

    search : async function (req, res) {
        const {page, limit,s} = req.body;
        let count = null;
        let queryAppend = ' where';
        let s1 = s;
        let s0 = s;
        if (s.indexOf("|") > 0) {
            s1 = s.split("|")[1];
            s0 = s.split("|")[0];
        }
        if (validEnum(s1)) {
            if (s1 === "ok") {
                queryAppend += ' (req.status = \'done\' or req.status = \'verified\' or req.status = \'deposited\')'
            }
            else {
                queryAppend += ' req.status = :s1'
            }
            queryAppend += (isUUID(s0) ? ' and (req.user_id = :s0 or req.jobber_id = :s0 or req.deposit_id = :s0)' : "")
        }
        else if (isUUID(s0)) {
            queryAppend += ' (req.user_id = :s0 or req.jobber_id = :s0 or req.deposit_id = :s0)'
        }
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."Requests" as req' + queryAppend, {
                replacements: {
                    s1: s1,
                    s0: s0,
                },
                nest: true
            });
            count = parseInt(count[0].count)
        }
        const result = await sequelize.query('select req.*,jobber.name as jobber_name, u.name as user_name, job.title as job_title from public."Requests" as req left outer join (select concat(name,\' \',family) as name,id from public."Jobbers") as jobber on jobber.id = req.jobber_id left outer join (select concat(name,\' \',family) as name,id from public."Users") as u on u.id = req.user_id left outer join (select title,id from public."Jobs") as job on job.id = req.job_id ' + queryAppend + ' order by created_at desc limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    s1: s1,
                    s0: s0,
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({"count" : count, items: result})
    }
};
