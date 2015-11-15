express = require('express')
logger = require('morgan')
passport = require('passport');
session = require('express-session');
cookieParser = require('cookie-parser');
bodyParser = require('body-parser');
router = require('./routes/index')
app = express()


app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.use(express.static('public'))
app.use(express.static('node_modules'))
app.use(express.static('node_modules/angular'))
app.use(express.static('node_modules/jquery/dist'))
app.use(express.static('node_modules/bootstrap/dist'))

app.use(logger('dev'))
app.use express.static(__dirname + 'public')
app.use(router)


app.use (req, res, next) ->
    err = new Error('Not Found')
    err.status = 404
    next err


if app.get('env') == 'development'
    app.use (err, req, res, next) ->
        res.status err.status or 500
        res.render('error', {message: err.message, error: err})


app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render('error', {message: err.message, error: {}})


module.exports = app
