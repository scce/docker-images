const express = require('express');
const app = express();
const expressWs = require('express-ws')(app);

app.get('/', function (req, res, next) {
    console.log('http');
    res.send('http: Hello World');
    res.end();
});

app.ws('/app/ws/', function (ws, req) {
    ws.on('message', function (msg) {
        console.log(msg);
        ws.send('ws: Hello World')
    });
    console.log('socket');
});

app.listen(8080);