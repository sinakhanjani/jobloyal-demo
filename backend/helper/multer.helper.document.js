const multer = require('multer');
const fs = require('fs');

const random = function () {
    let authCode = 1;

    while (authCode < 1000) {
        authCode = Math.floor(Math.random() * 10000);
    }

    return authCode;
};

const getNowInString = function () {
    // 2016-05-16-09-50-20
    const d = new Date();

    return `${d.getFullYear()}-${(`0${d.getMonth() + 1}`).slice(-2)}-${
        (`0${d.getDate()}`).slice(-2)}-${(`0${d.getHours()}`).slice(-2)}-${
        (`0${d.getMinutes()}`).slice(-2)}-${(`0${d.getSeconds()}`).slice(-2)}`;
};

const storage = multer.diskStorage({
    limits: {
        fileSize: 10000000
    },

    destination(req, file, cb) {
        const path = `uploads/documents/`;

        // directory existence check and creation
        if (!fs.existsSync(path)) {
            fs.mkdirSync(path, { recursive: true });
        }

        cb(null, path);
    },

    filename(req, file, cb) {
        file.ext = (file.originalname).split('.').pop();
        file.dateString = getNowInString();
        file.randomData = random();

        cb(null, `${file.dateString}-${file.fieldname}-${file.randomData}.${file.ext}`);
    },

    fileFilter(req, file, cb) {
        if (!file.originalname.match(/\.(jpg|jpeg|png)$/)) {
            return cb(new Error('Please upload an image'))
        }

        cb(undefined, true)
    }
});

module.exports = multer({ storage });
