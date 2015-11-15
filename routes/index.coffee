express = require('express')
router = express.Router()
api = require('./api')

router.use(api)

DB = require('../Utilities/DB')

router.get '/workspace',(req, res, next)->
    res.render('workspace', title:'Workspace', username: req.query.username)

router.get '*', (req, res, next) ->
    res.render('index', title: "Login")


module.exports = router
