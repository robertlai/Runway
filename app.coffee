express = require('express')
logger = require('morgan')
http = require('http')

DB = require('./Utilities/DB')
apiRouter = require('./routes/apiRouter')
pageRouter = require('./routes/pageRouter')


port = (process.env.PORT || 3000)


app = express()

app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

app.use(logger('dev'))

app.use(express.static(__dirname + '/public'))
app.use(express.static(__dirname + '/node_modules'))
app.use(express.static(__dirname + '/node_modules/angular'))
app.use(express.static(__dirname + '/node_modules/jquery/dist'))
app.use(express.static(__dirname + '/node_modules/bootstrap/dist'))


app.use('/api', apiRouter)
app.use('/', pageRouter)

app.set('port', port)
server = http.createServer(app)
server.listen(port)
