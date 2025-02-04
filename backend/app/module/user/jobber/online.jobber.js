const {Jobber,sequelize} = require("../../../../database/models")
const messages = require("../../../../helper/message.helper")

module.exports = {
    findByJob: async function (req,res) {
        const {latitude, longitude,page,job_id:jobId,limit} = req.body
        if (latitude && longitude && jobId) {
            try {
                const today = new Date();
                const todayAsString = today.toISOString().substring(0, 10);
                const jobbers = await sequelize.query('SELECT earth_distance(ll_to_earth(:latitude, :longitude),location.location) as distance,onlineJobbers.job_id,jobbers.id as jobber_id,jobbers.identifier as identifier,concat(upper(LEFT(jobbers.name,1)), upper(LEFT(jobbers.family,1))) as avatar,Rate.rate as rate, Rate.work as work_count FROM (SELECT DISTINCT ON (jobber_id) id,jobber_id,status,job_id,created_at FROM public."JobberDailyStatus" as t where t.created_at >= date :today and t.job_id = :job_id  order by jobber_id, id desc) as onlineJobbers INNER JOIN public."Jobbers" as jobbers ON onlineJobbers.jobber_id = jobbers.id LEFT OUTER JOIN public."Rates" as Rate ON Rate.jobber_id = onlineJobbers.jobber_id AND Rate.job_id = :job_id INNER JOIN (SELECT DISTINCT ON (jobber_id) id,jobber_id,location FROM public."JobberLocations" ORDER BY jobber_id, id DESC) AS location ON onlineJobbers.jobber_id = location.jobber_id where status = \'online\' AND onlineJobbers.job_id = :job_id order by distance asc LIMIT :limit offset :page;', {
                    model: Jobber,
                    replacements: {latitude: latitude, longitude: longitude, page: (page || 0) * (limit || 10), job_id: jobId,today: todayAsString,limit : limit || 10},
                    mapToModel: true
                });
                res.scaffold.add({items: jobbers})
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    findByService: async function (req,res) {
        const {latitude, longitude,page,job_id:jobId,service_id:serviceId,limit} = req.body
        if (latitude && longitude && jobId && serviceId) {
            try {
                const today = new Date();
                const todayAsString = today.toISOString().substring(0, 10);
                const jobbers = await sequelize.query('SELECT earth_distance(ll_to_earth(:latitude, :longitude),location.location) as distance,"JobberServices".job_id,jobbers.id as jobber_id,jobbers.identifier as identifier,concat(upper(LEFT(jobbers.name,1)), upper(LEFT(jobbers.family,1))) as avatar,Rate.rate as rate, Rate.work as work_count from public."JobberServices" INNER JOIN (SELECT DISTINCT ON (jobber_id) id,jobber_id,status,job_id,created_at FROM public."JobberDailyStatus" as t where t.created_at >= date :today and t.job_id = :job_id  order by jobber_id, id desc) as onlineJobbers ON onlineJobbers.jobber_id = "JobberServices".jobber_id INNER JOIN public."Jobbers" as jobbers ON onlineJobbers.jobber_id = jobbers.id LEFT OUTER JOIN public."Rates" as Rate ON Rate.jobber_id = onlineJobbers.jobber_id AND Rate.job_id = :job_id  INNER JOIN (SELECT DISTINCT ON (jobber_id) id,jobber_id,location FROM public."JobberLocations" ORDER BY jobber_id, id DESC) AS location ON onlineJobbers.jobber_id = location.jobber_id where status = \'online\' AND "JobberServices".job_id = :job_id AND "JobberServices".service_id = :service_id AND "JobberServices".deleted_at is null order by distance asc LIMIT :limit offset :page', {
                    model: Jobber,
                    replacements: {latitude: latitude, longitude: longitude, page: (page || 0) * (limit || 10), job_id: jobId,today: todayAsString,service_id: serviceId,limit:limit || 10} ,
                    mapToModel: true
                });
                res.scaffold.add({items: jobbers})
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    }
}
