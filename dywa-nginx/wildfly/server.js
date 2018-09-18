const express = require('express');
const app = express();
const expressWs = require('express-ws')(app);

app.use(function (req, res, next) {
    console.log('middleware');
    req.testing = 'testing';
    return next();
});

app.get('/', function (req, res, next) {
    console.log('get route', req.testing);
    res.send('http: Hello World');
    res.end();
});

app.ws('/app/ws/', function (ws, req) {
    ws.on('message', function (msg) {
        console.log(msg);
        ws.send('ws: Hello World')
    });
    console.log('socket', req.testing);
});

app.listen(8080);