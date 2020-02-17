// npm init
// npm install express --save && npm install express-async-handler --save

const express = require('express');
const asyncHandler = require('express-async-handler')

const path = require('path');
const fs = require('fs');

const app = express();

var asyncReadFile = function (path) {
    return new Promise(function (resolve, reject) {
        fs.readFile(path, 'utf-8', function (err, data) {
            if (err) {
                reject(err)
            }
            resolve(data)
        })
    }).catch((err) => {
        return err
    })
}

var sendMatchFile = function (filename, checksum, req, res, next) {
    checksum = checksum + "";
    const lines = checksum.split(/\r?\n/);

    // var lineCounter = 0;
    // lines.forEach((line) => {
    //     lineCounter++;
    //     if (lineCounter == 1) {
    //         checksum = line;
    //     }
    // });
    lines.every(function (item, index, arry) {
        if (index === 0) {
            checksum = item;
            return false;
        } else {
            return true;
        }
    });

    checksum = checksum.replace(/(^s*)|(s*$)/g, "");

    if ((checksum.length > 0) && req.query.hasOwnProperty('md5') && (req.query.md5 == checksum)) {
        var options = {
            root: path.join(__dirname, 'public'),
            dotfiles: 'deny',
            headers: {
                'x-timestamp': Date.now(),
                'x-sent': true
            }
        }

        res.sendFile(filename, options, function (err) {
            if (err) {
                next(err);
            } else {
                console.log('Sent: ', filename);
            }
        })
    } else {
        res.status(404).send('Sorry, we cannot find that!');
    }
}

app.get('/', (req, res) => {
    res.send('<p>Welocome!</p>');
});

app.get('/:name', asyncHandler(async(req, res, next) => {
    const fileName = req.params.name;
    const checkFile = path.join(__dirname, 'public', fileName + ".md5");
    const fileChecksum = await asyncReadFile(checkFile);

    sendMatchFile(fileName, fileChecksum, req, res, next);
}));

// app.get('news', (req, res) => {
//     res.send('<p>Hello news</p>');
// });

// app.post('about', (req, res) => {
//     res.send('<p>Hello about</p>');
// });

// app.get('/list*', (req, res) => {
//     res.send('<p>Hello list pages</p>');
// });

// // static resources
// app.use('/static', express.static(path.join(__dirname, 'public')))
// // http://localhost:8080/static/image
// // http://localhost:8080/static/images/bg.jpeg
// http://localhost:8080/static/index.html

// Use sendfile
// https://expressjs.com/zh-cn/api.html#res.sendFile
app.get('/static/:name', function (req, res, next) {
    // get all params
    // http://127.0.0.1:8080/static/config.yml?md5=<md5>
    // console.log(req.url);
    // var params = {};
    // if (req.url.indexOf('?') !== -1) {
    //     params = req.url.split("?");
    //     console.log(params);

    //     params = params[1].split("&");
    //     for (var $i = 0; $i < params.length; $i++) {
    //         var param = params[$i].split("=");
    //         console.log(param[0] + " = " + param[1]);
    //     }
    // } else {
    //     res.status(404).send('Sorry, we cannot find that!');
    //     res.end();
    // }
    const fileName = req.params.name;
    const checkFile = path.join(__dirname, 'public', fileName + ".md5");
    // send file with correct md5
    // openssl md5/sha1/sha256 -hex <filename>
    // (openssl md5 -hex <filename> | cut -d" " -f2) > <filename>.md5
    var fileChecksum = "";
    var lineCounter = 0;
    try {
        if (fs.existsSync(checkFile)) {
            const data = fs.readFileSync(checkFile, 'UTF-8');
            const lines = data.split(/\r?\n/);
            lines.forEach((line) => {
                lineCounter++;
                if (lineCounter == 1) {
                    fileChecksum = line;
                }
            });
        }
    } catch (err) {
        next(err);
    }

    sendMatchFile(fileName, fileChecksum, req, res, next);
});

// route that doesn't exist
app.use(function (req, res, next) {
    if (!req.route)
        return next(new Error('404'));
    next();
});

//Error Handling
app.use(function (err, req, res, next) {
    // console.error(err.stack);
    res.status(500).send('Sorry, we cannot find that!');
});

var server = app.listen(8080, 'localhost', () => {
    var host = server.address().address
    var port = server.address().port
    console.log('Server is running at http://%s:%s', host, port)
});

// //nginx proxy
//         location /files/ {
//                 proxy_pass http://127.0.0.1:8080/;
//                 proxy_set_header Host $host;
//                 proxy_set_header X-Real-IP $remote_addr;
//                 proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
//                 proxy_set_header X-Forwarded-Proto https;
//         }