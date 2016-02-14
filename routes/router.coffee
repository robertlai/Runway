express = require('express')


module.exports = (io) ->

    router = express.Router()

    apiRouter = require('./apiRouter')(io)
    pageRouter = require('./pageRouter')

    router.use('/api', apiRouter)
    router.use(pageRouter)

    return router
