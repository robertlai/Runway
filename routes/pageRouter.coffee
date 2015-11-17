express = require('express')
pageRouter = express.Router()


DB = require('../Utilities/DB')

pageRouter.get '/workspace',(req, res, next)->
    res.render('workspace', title:'Workspace', username: req.query.username)

pageRouter.get '*', (req, res, next) ->
    res.render('index', title: "Login")


module.exports = pageRouter
