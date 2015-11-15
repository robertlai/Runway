express = require('express')
router = express.Router()
api = require('./api')

router.use(api)

DB = require('../Utilities/DB')

router.get '/workspace',(req,res,next)->
    res.render('workspace',title:'Workspace')

router.get '/test',(req,res,next)->
    res.render('test',title:'Test')

router.get '/messages', (req, res, next) ->
    res.render('messages', title: "Messages")

router.get '/login', (req, res, next) ->
    res.render('login', title: "Login")

router.get '*', (req, res, next) ->
    res.render('index', title: 'Runway')

module.exports = router
