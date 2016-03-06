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

app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

app.use(logger('dev'))
app.use(cookieParser())
app.use(bodyParser.json())

app.use(express.static(__dirname + '/dist'))
app.use('/node_modules', express.static(__dirname + '/node_modules'))

app.use(favicon(__dirname + '/dist/images/favicon.ico'))

app.use(session({
    secret: 'ilovescotchscotchyscotchscotch'
    cookie: {
        maxAge: 30 * 60 * 1000
    }
    rolling: true
    resave: false
    saveUninitialized: false
}))
app.use(passport.initialize())
app.use(passport.session())

router = require('./routes/router')(io)
app.use(router)
require('./routes/socketRouter')(io)

port = (process.env.OPENSHIFT_NODEJS_PORT || process.env.PORT || 3000)
ip = process.env.OPENSHIFT_NODEJS_IP
app.set('port', port)
if ip?
    app.set('ip', ip)
    http.listen(port, ip)
else
    http.listen(port)
