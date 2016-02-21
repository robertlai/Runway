coffeeMiddleware = require('coffee-middleware')
fs = require('fs')
express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)

mongoose = require('mongoose')
logger = require('morgan')
passport = require('passport')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
favicon = require('serve-favicon')

mongoose.connect(
    if process.env.dbAddress?
        process.env.dbAddress
    else
        require('./dbcredentials.json').dbAddress
)

require('./passport')

app.set('views', __dirname + '/Views')
app.set('view engine', 'jade')

app.use coffeeMiddleware {
    src: __dirname + '/Public',
    compress: false
    debug: false
    bare: false
    encodeSrc: false
}

app.use(logger('dev'))
app.use(cookieParser())
app.use(bodyParser())

app.use(express.static(__dirname + '/Public'))
app.use('/node_modules', express.static(__dirname + '/node_modules'))

app.use(favicon(__dirname + '/Public/Images/favicon.ico'))

app.use(session({ secret: 'ilovescotchscotchyscotchscotch', cookie: { maxAge: 30 * 60 * 1000 }, rolling: true }))
app.use(passport.initialize())
app.use(passport.session())

router = require('./Routes/router')(io)
app.use(router)
require('./Routes/socketRouter')(io)

port = (process.env.OPENSHIFT_NODEJS_PORT || process.env.PORT || 3000)
ip = process.env.OPENSHIFT_NODEJS_IP
app.set('port', port)
if ip?
    app.set('ip', ip)
    http.listen(port, ip)
else
    http.listen(port)
