express = require('express')

loggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.sendStatus(401)

module.exports = (io) ->

    router = express.Router()

    apiRouter = require('./apiRouter')(io)
    authRouter = require('./authRouter')

    router.use('/api', loggedIn, apiRouter)
    router.use(authRouter)

    router.use (err, req, res, next) ->
        res.sendStatus(500).send(err)

    return router
