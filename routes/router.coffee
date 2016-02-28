express = require('express')

loggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.sendStatus(401)

module.exports = (io) ->

    router = express.Router()

    apiRouter = require('./apiRouter')(io)
    pageRouter = require('./pageRouter')

    router.use('/api', loggedIn, apiRouter)
    router.use(pageRouter)

    return router
