const {User,Jobber,Request,sequelize,Deposit,Payment,Transaction} = require("../../../../database/models");
const Sequelize = require("sequelize");
const Op = Sequelize.Op;

async function getCountOfUsers() {
    return await User.count()
}
async function getCountOfJobber()  {
    return await Jobber.count()
}

async function getCountOfRequest() {
    return await Request.count()
}
 async function getCountOfDoneRequest()  {
    return await Request.count({where: {
        [Op.or]:  [{status: 'done'},{status: 'verified'},{status: 'deposited'}]
    }})
}
async function getTotalDeposits() {
    const totalAmount = await Deposit.findAll({
        attributes: [
            [sequelize.fn('sum', sequelize.col('amount')), 'total_amount'],
        ],
        where: {
            status: 'success'
        }
    });
    return totalAmount[0].dataValues.total_amount;
}
async function getTotalPayment()  {
    const totalAmount = await Payment.findAll({
        attributes: [
            [sequelize.fn('sum', sequelize.col('payable_amount')), 'total_amount'],
        ],
        where: {
            [Op.or]:  [{status: 'success'},{status: 'wallet'}]
        }
    });
    return totalAmount[0].dataValues.total_amount;
}
async function getTotalTransaction () {
    const totalAmount = await Transaction.findAll({
        attributes: [
            [sequelize.fn('sum', sequelize.col('amount')), 'total_amount'],
        ]
    });
    return totalAmount[0].dataValues.total_amount;
}
async function getTotalAmountOfDoneRequest()  {
    const totalAmount = await Request.findAll({
        attributes: [
            [sequelize.fn('sum', sequelize.col('price')), 'total_amount'],
        ],
        where: {status: {[Op.or]: ['done','verified','deposited']}}
    });
    return totalAmount[0].dataValues.total_amount;
}

async function getRequestChartData () {
    const chartAllRequest = await sequelize.query('SELECT date_trunc(\'day\', "Requests".created_at) as "title", count(*) as "value", accepted.value as "acception_value" From public."Requests" LEFT OUTER JOIN (SELECT date_trunc(\'day\', created_at) as "title", count(*) as "value" From public."Requests" WHERE (status = \'verified\' or status = \'deposited\' or status = \'done\') group by 1 order by 1 desc ) as accepted on accepted.title = date_trunc(\'day\', "Requests".created_at)  group by 1,accepted.value order by 1 desc LIMIT 15',{
        nest: true
    });
    const data = chartAllRequest.map (e => {
        return {day: `${e.title.getDate()}` , all: parseInt(e.value), done: parseInt(e.acception_value || 0), canceled: e.value - e.acception_value}
    });
    return data.reverse();
}
async function getPaymentChartData () {
    const chartAllRequest = await sequelize.query('SELECT date_trunc(\'day\', created_at) as "title", sum(payable_amount) as "value" From public."Payments" where status = \'success\' group by 1 order by 1 desc LIMIT 15',{
        nest: true
    });
    const data = chartAllRequest.map (e => {
        return  { day: `${e.title.getDate()}` , payments: parseFloat(e.value) }
    });
    return data.reverse();
}
async function getWorstRatingJobberChart () {
    const rates = await sequelize.query('select jobber_id, avg(rate),CONCAT(jobber.name, \' \', jobber.family) as "name", jobber.avatar from public."Comments" as comment LEFT OUTER JOIN public."Jobbers" as jobber on jobber.id = comment.jobber_id where comment.created_at > current_date - interval \'7 day\'  group by jobber_id,jobber.name, jobber.family, jobber.avatar order by 2 asc limit 10', {
        nest: true
    });
    const data = rates.map(e => {
        return {
            avatar: e.avatar,
            name: e.name,
            meta: parseFloat(e.avg).toFixed(2) + " Stars",
            service_title: null,
            jobber_id: e.jobber_id,
            request_id: null
        }
    });
    return data;
}
async function getTheMostExpensiveServices () {
    const jobbers = await sequelize.query('SELECT requests.id, job.title ->> \'en\' as "title",CONCAT(jobber.name, \' \', jobber.family) as "name", jobber.avatar,jobber.id as jobber_id, requests.price FROM public."Requests" as requests LEFT OUTER JOIN public."Jobbers" as jobber on jobber.id = requests.jobber_id LEFT OUTER JOIN public."Jobs" as job on job.id = requests.job_id WHERE requests.created_at > current_date - INTERVAL \'7 day\' and (status = \'verified\' or status = \'done\' or status = \'deposited\') order by requests.price DESC limit 10', {
        nest: true
    });
    const data = jobbers.map(e => {
        return {
            avatar: e.avatar,
            name: e.name,
            meta: e.price + " CHF",
            service_title: e.title,
            jobber_id: e.jobber_id,
            request_id: e.id
        }
    });
    return data;
}
module.exports = {

    getReport : async function (req, res) {
        const userCount = await getCountOfUsers();
        const jobberCount = await getCountOfJobber();
        const requestCount = await getCountOfRequest();
        const requestDoneCount = await getCountOfDoneRequest();
        const totalDeposits = await getTotalDeposits();
        const totalPayment = await getTotalPayment();

        const totalTransaction = await getTotalTransaction();
        const totalAmountOfDoneRequest = await getTotalAmountOfDoneRequest();
        const requestChartData = await getRequestChartData();
        const paymentChartData = await getPaymentChartData();
        const worstRatingJobberChart = await getWorstRatingJobberChart();
        const theMostExpensiveServices = await getTheMostExpensiveServices();

        let response = {};
        const tags = [
            {
                title: "All User Count",
                value: userCount
            },
            {
                title: "All Jobber Count",
                value: jobberCount
            },
            {
                title: "All Requests Count",
                value: requestCount
            },
            {
                title: "All Done Job Count",
                value: requestDoneCount
            },
            {
                title: "Total Payment",
                value: (totalPayment || 0) + " CHF"
            },
            {
                title: "Total Pay To Jobber",
                value: (totalDeposits || 0) + " CHF"
            },
            {
                primary: true,
                title: "Net profit",
                value: (totalTransaction-totalAmountOfDoneRequest).toFixed(2),
                subvalue: "CHF"
            }
        ];
        response.tags = tags;
        response.requestChart = requestChartData;
        response.paymentChart = paymentChartData;
        response.worstRating = worstRatingJobberChart;
        response.expensive = theMostExpensiveServices;

        res.scaffold.add(response)

    }
};
