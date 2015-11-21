express = require('express')
app = express()
http = require('http').Server(app)
app.io = require('socket.io')(http)

logger = require('morgan')
passport = require('passport')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
flash = require('connect-flash')

DB = require('./Utilities/DB')

require('./passport')(passport)


port = (process.env.PORT || 3000)



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



app.use(session({ secret: 'ilovescotchscotchyscotchscotch' }))
app.use(passport.initialize())
app.use(passport.session())
app.use(flash())


require('./routes/apiRouter')(app, passport)
require('./routes/pageRouter')(app, passport)


app.set('port', port)

http.listen(port)