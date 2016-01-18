express = require('express')


module.exports = (passport, io) ->

    router = express.Router()

    apiRouter = require('./apiRouter')(passport, io)
    pageRouter = require('./pageRouter')(passport)

    router.use('/api', apiRouter)
    router.use(pageRouter)

    return router
