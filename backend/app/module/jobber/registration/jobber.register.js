const jwt = require('jsonwebtoken');
const { Jobber,JobberDocument, JobberStatic,sequelize,DeviceInfo,JobberDailyStatus} = require('../../../../database/models');
const tokenCreator = require('../utils/jobber.jwt.creator');
const messages = require('../../../../helper/message.helper');

exportTokenFromRequest = function (req) {
    return req.header('Authorization').replace('Bearer ', '')
};

getToken = async function (req,res) {
    const token = exportTokenFromRequest(req);
    try {
        const decode = jwt.verify(token, process.env.JWT_SECRET_PHONE_AUTH);
        const jobber = await getJobberByPhone(decode.phoneNumber);
        if (!jobber) {
            res.scaffold.success()
        }
        else {
            let region = jobber.region;
            if (req.body.region) {
                region = await changeRegionOfJobber(req.body.region, jobber.id)
            }
            const deviceInfo = await DeviceInfo.create({
                user_id: jobber.id
            });
            res.scaffold.add(tokenCreator.create(jobber.id, region, deviceInfo.id))
        }
    }
    catch (e) {
        res.scaffold.failed(e.message)
    }
};

changeRegionRequest = async function (req,res) {
    const {region} = req.body;
    const acceptedRegion = await changeRegionOfJobber(region, req.user.id);
    res.scaffold.add(tokenCreator.create(req.user.id, acceptedRegion,req.user.device))
};

changeRegionOfJobber = async function (region, jobberId) {
    let localeCode = 'en';
    if (region) {
        if (region === "fr" || region === "en") {
            localeCode = region
        }
    }
    await Jobber.update({
        region: localeCode
    },{
        where: {
            id: jobberId
        }
    });
    return localeCode
};

createNewJobber = async function (req,phoneNumber) {
    const { name,family,zip_code,identifier,region } = req.body;
    let localeCode = 'en';
    if (region) {
        if (region === "fr" || region === "en") {
            localeCode = region
        }
    }
    else {
        if (phoneNumber.startsWith("+33") || phoneNumber.startsWith("+41")) {
            localeCode = 'fr'
        }
    }
    return await Jobber.create({
        name: name,
        family: family,
        zip_code: zip_code,
        identifier: identifier.toLowerCase(),
        phone_number: phoneNumber,
        region: localeCode
    })
};

getJobberByPhone = async function (phoneNumber) {
    const jobber = await Jobber.findOne({
        where: { phone_number: phoneNumber},
        attributes: ['id','region']
    });
    if (!jobber) {
        return null
    }
    else {
        return jobber
    }
};

registerStep1 = async function (req,res) {
    const token = exportTokenFromRequest(req);
    try {
        const decode = jwt.verify(token, process.env.JWT_SECRET_PHONE_AUTH);
        const jobber = await getJobberByPhone(decode.phoneNumber);
        if (!jobber) {
            const newJobber = await createNewJobber(req, decode.phoneNumber);
            await JobberStatic.create({
                jobber_id: newJobber.id,
                sms_enabled: true,
                notification_enabled: true,
                pony_period: 1,
                card_number: ''
            });
            const deviceInfo = await DeviceInfo.create({
                user_id: newJobber.id
            });
            res.scaffold.add(tokenCreator.create(newJobber.id, newJobber.region, deviceInfo.id))
        }
        else {
            res.scaffold.failed(messages.jobberAlreadyRegistered)
        }
    }
    catch (e) {
        res.scaffold.failed(e)
    }
};

uploadAvatarForUser = async function (req,res) {
    Jobber.update(
        { avatar: `${process.env.API_ADDRESS}${req.file.path}` },
        { where: { id: req.user.id } })
        .then(result =>
            res.scaffold.add({url:`${process.env.API_ADDRESS}${req.file.path}`})
        )
        .catch(err =>
            res.scaffold.failed(err)
        )
};

uploadDocument = async function (req,res) {
    const jobber_id = req.user.id;
    JobberDocument.create(
        { doc_url: `${process.env.API_ADDRESS}${req.file.path}`,jobber_id: jobber_id})
        .then(result =>
            res.scaffold.add({url:`${process.env.API_ADDRESS}${req.file.path}`})
        )
        .catch(err =>
            res.scaffold.failed(err)
        )
};

completeProfile = async function (req,res) {
    const {email,address,gender,birthday,about_us} = req.body;
    if (email && address && (gender === true || gender === false) && birthday && about_us) {
        const about_us_without_number = about_us.replace(/\+?[0-9][0-9()\-\s+]{4,20}[0-9]/, ' ');
        if (validateEmail(email)) {
            Jobber.update(
                {
                    email: email || '',
                    address: address || '',
                    gender: gender || '',
                    birthday: birthday || '',
                    about_us: about_us_without_number || ''
                },
                {where: {id: req.user.id}})
                .then(result =>
                    res.scaffold.success()
                )
                .catch(err =>
                    res.scaffold.failed(err)
                )
        }
        else {
            res.scaffold.failed(messages.emailIsInvalid)
        }
    }
    else {
        res.scaffold.failed(messages.parameterIsRequire)
    }
};

editProfile = async function (req,res) {
    const {email,address,about_us} = req.body;
        if (validateEmail(email)) {
            const about_us_without_number = about_us.replace(/\+?[0-9][0-9()\-\s+]{4,20}[0-9]/, ' ');
            Jobber.update(
                {
                    email: email,
                    address: address,
                    about_us: about_us_without_number
                },
                {where: {id: req.user.id}})
                .then(result =>
                    res.scaffold.success()
                )
                .catch(err =>
                    res.scaffold.failed(err)
                )
        }
        else {
            res.scaffold.failed(messages.emailIsInvalid)
        }

};
deleteJobber = async function (req, res) {
    const date = new Date().toISOString().substring(0,10)
    try {
        await Jobber.update({
            phone_number: sequelize.literal('CONCAT(\''+ date +'del:\' , "phone_number")'),
            identifier: sequelize.literal('CONCAT(\''+ date +'del:\'  , "identifier")'),
        }, {
            where: {
                id: req.user.id
            }
        });
        await JobberDailyStatus.destroy({
            where: {
                jobber_id: req.user.id
            }
        });

        await DeviceInfo.destroy({
            where: {
                id: req.user.device
            }
        });

        await Jobber.destroy({
            where: {
                id: req.user.id
            }
        });
        res.scaffold.success()
    }
    catch (e) {
        res.scaffold.failed(messages.oneTimeDeleteAccountInDay)
    }

};

checkAvailableIdentifier = async function (req,res) {
    const {id} = req.body;
    const check = /^([_a-zA-Z][_a-zA-Z0-9.]{0,30})$/.test(id);
    if (check === true) {
        console.log(id.toLowerCase())
        const jobber = await Jobber.findOne({
            where: { identifier: id.toLowerCase()},
            attributes: ['id']
        });
        console.log(jobber)
        if (!jobber) {
            res.scaffold.success()
        }
        else {
            res.scaffold.failed(messages.idHasBeenExisted)
        }
    }
    else {
        res.scaffold.failed(messages.badCharacterInId)
    }

};

checkStepAuthorized = async function (req,res) {
    /* 0 => not authorized
     * 1 => pending
     * 2 => authorized - complete your profile
     * 3 => all thing is done **
     * -1 => last document not accepted and authorized of jobber equal to false */
    const jobber_id = req.user.id;
    const stepObject=  await getStepOfAuthorization(jobber_id);
    if (stepObject.doc) {
        delete stepObject.doc;
    }
    res.scaffold.add(stepObject)

};

getProfileJobber = async (req, res) => {
    const jobberId = req.user.id;
    const jobber = await Jobber.findOne({where: {id: jobberId},plain: true});
    const statics = await JobberStatic.findOne({where: {jobber_id: jobberId},plain: true});

    jobber.dataValues.credit = 0;
    const creditQuery = await sequelize.query('SELECT SUM(price) as total FROM public."Requests" WHERE jobber_id = :jobber_id AND (status = \'done\' OR status = \'verified\') AND paid = true AND deposit_id is null ;', {
        replacements: {
            jobber_id: jobberId
        },
        nest: true
    });
    if (creditQuery.length > 0 && creditQuery[0])
        jobber.dataValues.credit = parseFloat(creditQuery[0].total);

    if (statics)
        jobber.dataValues.statics = statics;
    jobber.dataValues.authority = await getStepOfAuthorization(jobberId,jobber);
    res.scaffold.add(jobber)
};

async function getStepOfAuthorization(jobber_id,jobber) {
    if (!jobber) {
        jobber = await Jobber.findOne({where: {id: jobber_id}});
    }
    const document = await JobberDocument.findOne({where: {jobber_id: jobber_id}, order: [['created_at','DESC']]});
    if (jobber.authorized === true) {
        if (jobber.avatar != null && jobber.email != null && jobber.address != null) {
            return ({status: 'ok',code:3,message: 'all thing is ok',doc: document.doc_url,updated_at: document.updated_at})
        }
        else {
            return ({status: 'authorized',code:2,message: 'complete your profile',doc: document.doc_url,updated_at: document.updated_at})
        }
    }
    else {
        if (document) {
            if (document.accepted == null) {
                return ({status: 'pending', code: 1, message: 'wait until check your identity',doc: document.doc_url,updated_at: document.updated_at})
            } else if (document.accepted === true) {
                return ({status: 'authorized',code:2,message: 'complete your profile',doc: document.doc_url,updated_at: document.updated_at})
            }
            else {
                return ({status: 'failed',code:-1,message: 'please try again with another document',doc: document.doc_url,updated_at: document.updated_at})
            }
        }
        else {
            return ({status: 'unidentified',code:0,message: 'please send a document'})
        }
    }

}

function validateEmail(email) {
    const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
}

logout = async function (req, res) {
    try {
        const today = new Date().toISOString().substring(0, 10);
        await sequelize.query('insert into "JobberDailyStatus" (status,jobber_id,job_id,created_at) select \'offline\',jobber_id, job_id,NOW() from (select distinct on (ts.jobber_id,ts.job_id) ts.status,ts.jobber_id,ts.job_id,NOW() from "JobberDailyStatus" as ts where ts.jobber_id = :jobber_id order by ts.jobber_id,ts.job_id,id desc) as sq where sq.status = \'online\'', {
            replacements: {jobber_id: req.user.id, today: today},
            nest: true,
        });
         await DeviceInfo.destroy({
            where: {
                id: req.user.device
            }
        });
         res.scaffold.success()
    }
    catch (e) {
        res.scaffold.failed(e.message)
    }
};

module.exports = {
    logout,
    registerStep1,
    getToken,
    uploadAvatarForUser,
    completeProfile,
    editProfile,
    checkAvailableIdentifier,
    uploadDocument,
    changeRegionRequest,
    checkStepAuthorized,
    getProfileJobber,
    deleteJobber,
    getStepOfAuthorization};
