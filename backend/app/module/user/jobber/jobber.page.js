const {Jobber,sequelize,Comment} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper")
async function getPage (req,res) {
    const {jobber_id,job_id,latitude,longitude} = req.body;
    if (jobber_id && job_id) {
        const today = new Date();
        const todayAsString = today.toISOString().substring(0, 10);
        try {
            const jobberPage = await sequelize.query('SELECT jobber.identifier as identifier,jobber.about_us as about_me, concat(upper(LEFT(jobber.name,1)), upper(LEFT(jobber.family,1))) as avatar, rate.rate as rate, rate.work as work_count, (rate.star1 + rate.star2 + rate.star3 + rate.star4 + rate.star5) as total_comments ,COALESCE(jobberDailyStatus.status,\'offline\') as status,earth_distance(ll_to_earth(:latitude, :longitude),Location.location) as distance,json_agg(s) as services FROM public."Jobbers" as jobber LEFT OUTER JOIN (SELECT "jobber.jobberService".id as id ,service.title as title,"jobber.jobberService".price as price, unit.title as unit, "jobber.jobberService".jobber_id as jobber_id FROM public."JobberServices" as "jobber.jobberService" INNER JOIN public."Services" as service ON service.id = "jobber.jobberService".service_id LEFT OUTER JOIN public."Units" as unit ON unit.id = "jobber.jobberService".unit_id WHERE "jobber.jobberService".job_id = :job_id AND "jobber.jobberService".deleted_at is null) as s ON s.jobber_id = jobber.id LEFT OUTER JOIN public."Rates" as rate ON rate.jobber_id = jobber.id AND rate.job_id = :job_id LEFT OUTER JOIN (SELECT * FROM public."JobberDailyStatus" as jobberDailyStatus WHERE jobberDailyStatus.job_id = :job_id AND jobberDailyStatus.jobber_id = :jobber_id AND jobberDailyStatus.created_at >= date :today order by id desc limit 1) as jobberDailyStatus ON 1 = 1 LEFT OUTER JOIN (select location,id from public."JobberLocations" as jl where jl.jobber_id = :jobber_id order by id desc limit 1) as Location ON 1 = 1 WHERE jobber.id = :jobber_id GROUP BY jobber.id,rate.rate,rate.work,rate.star1,rate.star2,rate.star3,rate.star4,rate.star5,jobberDailyStatus.status,Location.location', {
                replacements: {
                    jobber_id: jobber_id,
                    job_id: job_id,
                    today: todayAsString,
                    latitude: latitude || null,
                    longitude: longitude || null
                },
                nest: true
            });
            const jobberComments = await sequelize.query('SELECT comments.id,sv.title as service_title, comments.comment as comment, comments.rate as rate FROM public."Comments" as comments LEFT OUTER JOIN public."Services" as sv ON comments.service_id = sv.id WHERE comments.jobber_id = :jobber_id AND comments.comment is not null AND comments.comment != \'\' AND comments.job_id = :job_id ORDER BY comments.id DESC LIMIT 3',{
                replacements: {
                  job_id: job_id,
                  jobber_id: jobber_id,
                },
                nest: true
            });
            if (jobberPage.length > 0 && jobberPage[0] !== null) {
                const page = jobberPage[0];
                if (page.services[0] == null)
                    page.services = null;
                else {
                    page.services.forEach(item => {
                        delete item.jobber_id;
                        item.commission = parseInt(process.env.COMMISSION)
                    })
                }
                page['comments'] = jobberComments.length > 0 ? jobberComments : null;
                res.scaffold.add(page)
            }
            else {
                res.scaffold.failed(messages.notFound)
            }
        }
        catch (e) {
            res.scaffold.failed(e.message)
        }
    }
}


module.exports = {
    getPage
};
