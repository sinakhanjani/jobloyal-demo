const express = require('express');
const app = express();
const bodyParser = require('body-parser');
require('dotenv').config();
const router = require("./app/router");
const path = require('path');

const admin = require("firebase-admin");
const serviceAccount = require("./jobloyal-81f1b-firebase-adminsdk-9yfq0-c9033a859e");
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});
app.use(bodyParser.json());

router(app);
app.use('/uploads',express.static('uploads'));

app.get('/app/terms', function (req, res) {
    if (req.query && req.query.dark === "true") {
        res.sendFile(path.join(__dirname, 'view', 'terms_dark.html'));
    }
    else {
        res.sendFile(path.join(__dirname, 'view', 'terms.html'));
    }
});

app.get('/*', function (req, res) {
    res.sendFile(path.join(__dirname, 'view', 'index.html'));
});
app.use(function (err, req, res, next) {
    res.sendFile(path.join(__dirname, 'view', 'index.html'));
});

app.listen(8080);
