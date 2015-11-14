express = require('express')
router = express.Router()
api = require('./api')

router.use(api)

DB = require('../Utilities/DB')

router.get '/messages', (req, res, next) ->
    res.render('messages', title: "Messages")

router.get '*', (req, res, next) ->
    res.render('index', title: 'Runway')


module.exports = router
