express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)

logger = require('morgan')
passport = require('passport')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
flash = require('connect-flash')
favicon = require('serve-favicon')

DB = require('./Utilities/DB')

require('./passport')(passport)

port = (process.env.OPENSHIFT_NODEJS_PORT || process.env.PORT || 3000)
ip = process.env.OPENSHIFT_NODEJS_IP


app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

app.use(logger('dev'))
app.use(cookieParser())
app.use(bodyParser())

app.use(express.static(__dirname + '/public'))
app.use(express.static(__dirname + '/node_modules'))
app.use(express.static(__dirname + '/node_modules/angular'))
app.use(express.static(__dirname + '/node_modules/jquery/dist'))
app.use(express.static(__dirname + '/node_modules/bootstrap/dist'))
app.use(express.static(__dirname + '/node_modules/dropzone/dist'))
app.use(express.static(__dirname + '/node_modules/jquery-ui-touch-punch'))
app.use(express.static(__dirname + '/node_modules/angular-animate'))
app.use(express.static(__dirname + '/node_modules/angular-ui-bootstrap'))
app.use(express.static(__dirname + '/node_modules/angular-ui-router/release'))

app.use(favicon(__dirname + '/public/images/favicon.ico'))

app.use(session({ secret: 'ilovescotchscotchyscotchscotch', cookie:{ maxAge: 30*60*1000 }, rolling: true }))
app.use(passport.initialize())
app.use(passport.session())
app.use(flash())

router = require('./routes/router')(passport)
app.use(router)
require('./routes/socketRouter')(io)

app.set('port', port)
if ip
    app.set('ip', ip)
    http.listen(port, ip)
else
    http.listen(port)
