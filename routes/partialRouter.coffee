express = require('express')


module.exports = (isLoggedIn) ->

    partialRouter = express.Router()

    partialRouter.get '/groups', isLoggedIn, (req, res) ->
        res.render('groups')

    partialRouter.get '/manage', isLoggedIn, (req, res) ->
        res.render('manage')


    return partialRouter
